#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright(c) 2017-2019 Jonas Sjöberg  <jonas[a]jonasjberg.com>

# TODO: Implement implementation!
# TODO: Implement implementation!
# TODO: Implement implementation!

# ____________________________________________________________________________
#
# Initial:
#
#     ~/Documents/bar_A_B_2017.txt
#     ~/Documents/bar_A_B_2018.txt
#     ~/Documents/bar_A_C_2019.txt
#     ~/Documents/foo_2017.txt
#     ~/Documents/foo_2018.txt
#
# After running 'flat_to_nested.py ~/Documents/*.txt':
#
#     ~/Documents/bar/A/B/2017.txt
#     ~/Documents/bar/A/B/2018.txt
#     ~/Documents/bar/A/C/2019.txt
#     ~/Documents/foo/2017.txt
#     ~/Documents/foo/2018.txt
#
# -- Only process groups of files that all share the same parent directory.
#    TODO: From any number of given arguments, first gather groups of files.

import argparse
import collections
import logging
import os
import pathlib
import re
import sys


_SELF_BASENAME = pathlib.Path(__file__).name
RE_SUBSTRING_SEPS = re.compile(r'[ _-]')
IGNORED_DIRECTORY_BASENAMES = frozenset([
    '.azure-pipelines',
    '.backup',
    '.bzr',
    '.cache',
    '.ci',
    '.circleci',
    '.config',
    '.data',
    '.dropbox',
    '.git',
    '.github',
    '.gradle',
    '.hg',
    '.hidden',
    '.history',
    '.hypothesis',
    '.icn',
    '.jenkins',
    '.local',
    '.metadata',
    '.mplayer',
    '.persistent',
    '.settings',
    '.settings',
    '.split',
    '.svn',
    '.swp',
    '.temp',
    '.thumbs',
    '.tmp',
    '.travis',
    '.undo',
    '.versions',
    '.vim',
    '.vs',
    '.vscode',
    '.workspace',
    '__pycache__',
    'cache',
])


def common_substrings(string_list, max_count=1, separators=RE_SUBSTRING_SEPS):
    substring_counter = collections.Counter()
    for string in string_list:
        _substrings = separators.split(string)
        substring_counter.update(_substrings)

    most_common_substrings = substring_counter.most_common(max_count)
    result = dict()
    for substring in most_common_substrings:
        for string in string_list:
            if string.startswith(substring):
                result[substring]


def process_directory(dirpath):
    directory_basenames = [
        p.name for p in dirpath.iterdir() if p.is_dir()
    ]
    # TODO: HACKS!
    assert len(directory_basenames) > 1, 'FIX ME!'

    # substring_counter = collections.Counter()
    basename_parts_counts = collections.defaultdict(int)
    basename_infos = dict()

    for basename in sorted(directory_basenames):
        basename_parts = RE_SUBSTRING_SEPS.split(basename)
        if len(basename_parts) <= 1:
            continue

        basename_infos[basename] = basename_parts

        print(basename_parts)
        basename_parts_counts[basename_parts[0]] += 1

        # substring_counter.update(basename_parts)

    # print(substring_counter)
    # print(list(substring_counter.elements()))
    # TODO: HACKS!
    candidates = [
        substring for substring, count in basename_parts_counts.items()
        if count > 1
    ]
    print('CANDIDATES:')
    print(candidates)

    to_rename = list()

    # TODO: HACKS!
    for candidate in candidates:
        for basename, basename_parts in basename_infos.items():
            # print('{!s} :: {!s}'.format(basename, basename_parts))
            if candidate == basename_parts[0]:
                to_rename.append({
                    'src': basename,
                    # TODO: HACKS!
                    # TODO: Return full absolute paths!
                    # TODO: This needs to take the splitting in account in
                    # order to reconstruct the original basename WITHOUT the
                    # common prefix part that is being turned into a common
                    # subdirectory.
                    'dest': basename_parts[0] + '/' + '_'.join(basename_parts[1:]),
                })

    import pprint
    pprint.pprint(to_rename)


def is_ignored_path(dirpath):
    return dirpath.name in IGNORED_DIRECTORY_BASENAMES


def main(options={}):
    if options.get('verbose', False):
        log_format = '%(asctime)s.%(msecs)03d %(levelname)-6.6s %(message)-s'
        log_level = logging.DEBUG
    else:
        log_format = '%(asctime)s %(levelname)-6.6s %(message)-s'
        log_level = logging.INFO

    logging.basicConfig(
        level=log_level,
        format=log_format,
        datefmt='%Y-%m-%d %H:%M:%S',
    )
    LOG = logging.getLogger(__name__)

    for maybe_path in options.get('paths', []):
        try:
            path = pathlib.Path(maybe_path).resolve()
        except FileNotFoundError:
            LOG.warning('Skipped unresolvable path: %s', maybe_path)
            continue

        if not path.is_dir():
            LOG.info('Ignored non-directory: %s', path)
            continue

        if is_ignored_path(path):
            LOG.debug('Ignored path: %s', path)
            continue

        if not os.access(str(path), os.R_OK):
            LOG.error('Skipped unreadable directory: "{!s}"'.format(path))
            continue

        if not os.access(str(path), os.W_OK):
            LOG.error('Skipped unwritable directory: "{!s}"'.format(path))
            continue

        LOG.debug('Processing directory: %s', path)
        process_directory(path)


def parse_cli_args():
    parser = argparse.ArgumentParser(
        prog=_SELF_BASENAME,
        description='''
Converts a flat collection of files to a nested directory structure by finding
common substrings in file names, creating directories and finally moving and
renaming the related files.
''',
        epilog='Written by Jonas Sjöberg in 2017.'
    )

    parser.add_argument(
        dest='paths',
        metavar='PATH',
        nargs='*',
        help='Path(s) to a directory of files to handle.'
    )
    parser.add_argument(
        '-v', '--verbose',
        dest='verbose',
        action='store_true',
        help='Increase program verbosity.'
    )
    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = parse_cli_args()
    options = {
        'paths': args.paths,
        'verbose': args.verbose,
    }

    exit_success = main(options)
    sys.exit(0 if exit_success else 1)
