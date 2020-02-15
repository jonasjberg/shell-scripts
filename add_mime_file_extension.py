#!/usr/bin/env python3

# Modifies file extensions based on the detected MIME-type.
# First written 2019-12-28 by <jonas@jonasjberg.com>

import argparse
import logging
import pathlib
import subprocess
import sys


sys.exit('TODO: WIP! Needs testing and further development!')


LOG = logging.getLogger(__name__)


USE_AS_IS = object()


def examine_application_octet_stream(filepath, mimetype):
    USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF = {
        '.DS_Store',
        '.viminfo',
    }

    if filepath.name in USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF:
        return USE_AS_IS

    filepathstr = str(filepath)
    if filepathstr.endswith('3gp'):
        return '3gdp'
    if filepathstr.endswith('webm'):
        return 'webm'


def examine_text_plain(filepath, mimetype):
    USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF = {
        '.tmux.conf',
    }

    if filepath.name in USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF:
        return USE_AS_IS

    if filepath.name.startswith('.'):
        return filepath.suffix


def examine_message_rfc_822(filepath, mimetype):
    if str(filepath).endswith('.mhtml'):
        return 'mhtml'


IGNORED_MIMETYPES = {
    'inode/x-empty',
}

# TODO: BUT we want to exclude ~/.python_history! So we need exclusion rules,
#       like "match this but ALSO DO NOT MATCH THIS" ..
MIMETYPE_EXTENSION_LOOKUP = {
    'application/octet-stream': examine_application_octet_stream,
    'application/pdf': 'mp4',
    'application/zip': 'zip',
    'image/jpeg': 'jpg',
    'message/rfc822': examine_message_rfc_822,
    'text/html': 'html',
    'text/plain': examine_text_plain,
    'text/x-python': 'py',
    'video/mp4': 'mp4',
}


def get_file_mimetype(filepath):
    completed_process = subprocess.run(
        ['file', '--mime-type', '--brief', '--', str(filepath)],
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )
    mimetype = completed_process.stdout.decode('utf-8').strip()
    return mimetype


def main(options):
    assert isinstance(options, dict)

    for path in options['filepaths']:
        try:
            filepath = pathlib.Path(path).resolve()
        except FileNotFoundError:
            continue

        if not filepath.is_file():
            continue

        mimetype = get_file_mimetype(filepath)
        if mimetype in IGNORED_MIMETYPES:
            continue

        if mimetype not in MIMETYPE_EXTENSION_LOOKUP:
            LOG.warning(
                'Unhandled MIME-type %s from file %s', mimetype, filepath
            )
            continue

        truth = MIMETYPE_EXTENSION_LOOKUP[mimetype]
        if callable(truth):
            extension = truth(filepath, mimetype)
        elif isinstance(truth, str):
            extension = truth
        else:
            LOG.critical('Unhandled truth %r from file %s', truth, filepath)
            continue

        if extension == USE_AS_IS:
            LOG.debug('Skipping file %s', filepath)
            continue

        if filepath.suffix[1:] == extension:
            LOG.debug('Skipping file %s', filepath)
            continue

        print('Would have renamed: {!s} ({!s}) (extension={!s})'.format(filepath, mimetype, extension))

    return True


def parse_args():
    parser = argparse.ArgumentParser(
        usage='%(prog)s (options] [glob_pattern] [directories]',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument('filepaths', type=str, nargs='+')

    args = parser.parse_args()

    if not args.filepaths:
        parser.error('Argument filepaths must be one or more files')

    return {
        'filepaths': args.filepaths,
    }


if __name__ == '__main__':
    options = parse_args()
    sys.exit(main(options))
