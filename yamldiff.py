#!/usr/bin/env python3

"""
Compares YAML file data. Ignores formatting, comments, etc.

Both YAML files are parsed and immediately serialized back into a string.
This round-trip effectively normalizes the YAML data prior to comparison.

Returns 0 if the compared files contain equivalent data, otherwise 1.
Returns 70 on errors.
"""

import argparse
import difflib
import logging
import pathlib
import sys
import yaml


SELF_BASENAME = str(pathlib.Path(__file__).name)
LOG = logging.getLogger(SELF_BASENAME)


def load_yaml_file(filehandle):
    try:
        return yaml.safe_load(filehandle)
    except (UnicodeDecodeError, ValueError, yaml.YAMLError) as exc:
        LOG.error('Unable to load YAML from file handle %s', filehandle)
        LOG.exception(exc)
        raise exc


class CustomYamlDumper(yaml.SafeDumper):
    # Fixes PyYAML output not conforming to the YAML specification.
    def increase_indent(self, flow=False, indentless=False):
        return super(CustomYamlDumper, self).increase_indent(flow, False)

    # The PyYAML dumper uses an 'ignore_aliases' method to prevent primitive
    # types from being "anchored" and "referenced" in this way. Override the
    # method to always ignore alises independent of any object passed in.
    # Can cause infinite recursion in some cases!
    def ignore_aliases(self, data):
        return True



def serialize_yaml(data):
    bytestring = yaml.dump(
        data,
        Dumper=CustomYamlDumper,
        encoding='utf8',
        default_flow_style=False,
        width=160,
        indent=2,
    )
    return bytestring.decode('utf8')


# TODO(jonas): This actually deletes either dict keys but also list values.
def recursively_delete_dict_key(data, keys_to_delete=('do', 'not_want')):
    if isinstance(data, dict):
        # Make 'dict_keys' a list since it can not change size during iteration.
        for key in list(data.keys()):
            if key in keys_to_delete:
                LOG.debug('Deleting key "%s" value "%s"', key, data[key])
                del data[key]
            else:
                recursively_delete_dict_key(data[key], keys_to_delete)

    elif isinstance(data, list):
        for idx in reversed(range(len(data))):
            for key_to_delete in keys_to_delete:
                if data[idx] == key_to_delete:
                    LOG.debug('Deleting index "%s" value "%s"', key_to_delete, data[idx])
                    del data[idx]
                else:
                    recursively_delete_dict_key(data[idx], key_to_delete)
    else:
        # Neither dict nor list, do nothing.
        pass


def cli_main(args=sys.argv[1:]):
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog='First written by Jonas Sjöberg <jonas@jonasjberg.com>',
        prog=SELF_BASENAME,
    )

    parser.add_argument(
        dest='filepaths',
        help='''
File(s) to read. Use "-" to read from stdin.
''',
        metavar='FILEPATH',
        nargs=2,
        type=argparse.FileType('r', encoding='utf8')
    )

    parser.add_argument(
        '--coerce-numbers',
        action='store_true',
        default=False,
        dest='coerce_numbers',
        help='''
Treat string numbers and integers with the same value as equal.
Default: %(default)s
''',
    )

    parser.add_argument(
        '--ignore-keys',
        action='append',
        default=[],
        dest='ignore_keys',
        help='''
List of keys to filter out from all input data prior to comparison.
Default: %(default)s
''',
    )

    parser.add_argument(
        '--ignore-ordering',
        action='store_true',
        default=False,
        dest='ignore_element_ordering',
        help='''
Ignore order of elements in lists.
Default: %(default)s
''',
    )

    parser.add_argument(
        '-v',
        action='count',
        default=0,
        dest='verbosity',
        help='''
Increase output verbosity. Add additional "-v" to further increase the log
level. E.G., "-vvv" will enable debug output.
Default: %(default)s
''',
    )

    parsed_args = parser.parse_args(args)

    loglevel = {
        0: logging.WARNING,
        1: logging.INFO,
        2: logging.DEBUG,
    }.get(parsed_args.verbosity, logging.DEBUG)
    logging.basicConfig(
        format='%(name)s: %(levelname)8s %(message)s',
        level=loglevel,
    )

    filepath_a, filepath_b = parsed_args.filepaths

    if parsed_args.coerce_numbers:
        # Coerce integer values into strings.
        def _represent_int_as_string(dumper, data):  # pylint: disable=unused-argument
            return yaml.ScalarNode('tag:yaml.org,2002:str', str(data))

        CustomYamlDumper.add_representer(int, _represent_int_as_string)

    if parsed_args.ignore_element_ordering:
        def _represent_sorted_sequence(dumper, data):
            # pylint: disable=unused-argument
            # pylint: disable=unnecessary-lambda

            if all(isinstance(x, (int, float)) for x in data):
                # Sort numbers lexicographically instead of numerically.
                sorting_function = lambda x: str(x)
            else:
                # Equivalent to the default sorting behaviour.
                sorting_function = lambda x: x

            try:
                sorted_data = sorted(data, key=sorting_function)
            except TypeError as exc:
                # Might be this:
                # TypeError: '<' not supported between instances of 'dict' and 'dict'
                LOG.debug(exc)
                sorted_data = data

            return dumper.represent_sequence('tag:yaml.org,2002:seq', sorted_data)

        CustomYamlDumper.add_representer(list, _represent_sorted_sequence)
        CustomYamlDumper.add_representer(tuple, _represent_sorted_sequence)

    try:
        data_a = load_yaml_file(filepath_a)
        data_b = load_yaml_file(filepath_b)
    except Exception as exc:  # pylint: disable=broad-except
        LOG.critical('Caught top-level exception!')
        LOG.exception(exc)
        return 70

    if parsed_args.ignore_keys:
        LOG.debug('Elements to compare; A: %d, B: %d', len(data_a), len(data_b))
        LOG.debug('Filtering out dict key(s): %s', ', '.join(parsed_args.ignore_keys))
        recursively_delete_dict_key(data_a, parsed_args.ignore_keys)
        recursively_delete_dict_key(data_b, parsed_args.ignore_keys)
        LOG.debug('Elements to compare; A: %d, B: %d', len(data_a), len(data_b))

    data_a_text = serialize_yaml(data_a)
    data_b_text = serialize_yaml(data_b)
    LOG.debug('Serialized data from file "%s":\n%s', filepath_a.name, data_a_text)
    LOG.debug('Serialized data from file "%s":\n%s', filepath_b.name, data_b_text)

    diff_generator = difflib.unified_diff(
        data_a_text.splitlines(),
        data_b_text.splitlines(),
        fromfile=filepath_a.name,
        tofile=filepath_b.name,
    )
    diff = '\n'.join(diff_generator)
    if not diff:
        LOG.debug('Diff is empty, normalized data is equivalent')
        return 0

    print(diff)
    return 1


if __name__ == '__main__':
    sys.exit(cli_main())
