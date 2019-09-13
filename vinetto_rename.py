#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#   Written in 2017 by Jonas Sjöberg
#   http://www.jonasjberg.com
#   https://github.com/jonasjberg
#   _____________________________________________________________________
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   _____________________________________________________________________


from datetime import datetime
import os
import logging
import re
import shutil
import sys
import unicodedata

PROGRAM_NAME = os.path.basename(__file__)
RE_VALID_FILENAME = re.compile(r'\d{4}.jpg')
RE_REPORT = re.compile(
    r'<TT>(?P<index>\d{4}) -- (?P<timestamp>.*) -- (?P<filename>.*)</TT><BR>'
)

TIMESTAMP_FORMAT = '%a %b %d %H:%M:%S %Y'  # Fri Sep 26 18:15:14 2013
# locale.setlocale(locale.LC_TIME, "en_US")


# # Make sure required commands are available.
# if not shutil.which('vinetto'):
#     print('This program requires "{c}" to run. Make sure that "{c}" is '
#           'installed and executable.'.format(c='vinetto', file=sys.stderr))
#     raise SystemExit(1)


def validate_path(arg):
    if arg and os.path.exists(arg):
        if arg.startswith('~/'):
            arg = os.path.expanduser(arg)
        if os.access(arg, os.W_OK) and os.access(arg, os.R_OK):
            return arg

    raise argparse.ArgumentTypeError('Invalid path: "{}"'.format(arg))


def slugify(string):
    s = unicodedata.normalize('NFKD', string).encode('ascii', 'ignore').decode()
    s = re.sub(r'[^\w\s\-_.]', '', s).strip()
    s = re.sub(r'[-\s]+', '-', s)
    s = re.sub(r'[.]{2,}', '.', s)
    s = re.sub(r'[_]{2,}', '_', s)
    s = re.sub(r'[-]{2,}', '-', s)
    return s


def read_html_report(file_path):
    if os.path.isfile(file_path):
        with open(file_path, encoding='latin-1') as f:
            return f.readlines()
    return None


def get_images(image_path):
    out = set()

    for path_ in image_path:
        if os.path.exists(path_):
            path_ = os.path.realpath(path_)
        else:
            continue

        if os.path.isdir(path_):
            for f in os.listdir(path_):
                if RE_VALID_FILENAME.match(f):
                    file_path = os.path.normpath(os.path.join(path_, f))
                    if os.path.isfile(file_path):
                        out.add(file_path)
        elif os.path.isfile(path_):
            if RE_VALID_FILENAME.match(os.path.basename(path_)):
                out.add(path_)

    return out


def parse_report_contents(raw_report):
    out = {}

    if raw_report:
        for line in raw_report:
            # '<TT>0002 -- Fri Sep 26 18:15:14 2010 -- jag.JPG</TT><BR>
            match = RE_REPORT.match(line)
            if match:
                timestamp = match.group('timestamp')
                timestamp = timestamp.replace('&nbsp;', ' ').strip()

                try:
                    dt = datetime.strptime(timestamp, TIMESTAMP_FORMAT)
                except ValueError as e:
                    log.debug('Unable to extract datetime from "{}": '
                              '{}'.format(str(timestamp), e))
                else:
                    timestamp = dt.strftime('%Y-%m-%dT%H%M%S')

                filename = match.group('filename')
                filename = slugify(filename)

                index = match.group('index')
                out[index] = (timestamp, filename)
    return out


def main(opts):
    time_started = datetime.now().strftime('%Y-%m-%dT%H%M%S')
    log.debug('[{}] {} Started ..'.format(time_started, PROGRAM_NAME))

    images = get_images(opts.image_path)
    log.info('Found {} images:'.format(len(images)))
    for i in images:
        log.info("{!s}".format(i))

    raw_report = read_html_report(opts.vinetto_html_report)
    file_info_dict = parse_report_contents(raw_report)

    if opts.verbose:
        for k, v in file_info_dict.items():
            index = k
            timestamp, filename = file_info_dict[k]
            print(('    index: {}\n'
                   'timestamp: {}\n'
                   ' filename: "{}"\n').format(index, timestamp, filename))

    if not os.path.exists(opts.dest_path):
        dest_path = opts.dest_path
        try:
            os.mkdir(dest_path)
        except (OSError, IOError) as e:
            log.critical(str(e))
            log.critical('Aborting ..')
            sys.exit(1)
    elif os.path.isdir(opts.dest_path):
        _dest_base = '{}_{}'.format(PROGRAM_NAME,
                                   datetime.now().strftime('%Y-%m-%dT%H%M%S'))
        dest_path = os.path.normpath(os.path.join(opts.dest_path, _dest_base))
        try:
            os.mkdir(dest_path)
        except (OSError, IOError) as e:
            log.critical(str(e))
            log.critical('Aborting ..')
            sys.exit(1)
    else:
        log.critical('Invalid destination path: "{!s}"'.format(opts.dest_path))
        sys.exit(1)

    if not os.path.isdir(dest_path):
        log.critical('Invalid destination path: "{!s}"'.format(opts.dest_path))
        sys.exit(1)


    # TODO: HACK! Patience has run out. This is so bad, but I need to be done ..
    for image in images:
        _image_base = os.path.basename(image).replace('.jpg', '')
        if _image_base in file_info_dict:
            log.debug('Found "{!s}" in file_info_dict'.format(image))

            index = _image_base
            timestamp, filename = file_info_dict[index]
            if filename.endswith('.JPG'):
                filename = filename.replace('.JPG', '.jpg')
            if not filename.endswith('.jpg'):
                filename = '{}.jpg'.format(filename)

            new_name = '{}_{}'.format(timestamp, filename)
            image_dest = os.path.normpath(os.path.join(dest_path, new_name))
            if os.path.exists(image_dest):
                log.error('Skipping (exists): "{}"'.format(image_dest))
                continue

            try:
                shutil.copy(image, image_dest)
            except Exception as e:
                log.critical(str(e))
                continue
            else:
                log.info('Copied "{}" to "{}"'.format(image, image_dest))

    time_finished = datetime.now().strftime('%Y-%m-%dT%H%M%S')
    log.debug('[{}] {} Finished'.format(time_finished, PROGRAM_NAME))


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        prog=PROGRAM_NAME,
        description='Copy images extracted with "vinetto" from "Thumbs.db" '
                    'files to a destination with file names created from '
                    'contents of a "vinetto" HTML report.',
        epilog='Written by Jonas Sjöberg in 2017. This is pre-alpha software!'
    )

    parser.add_argument(
        '--report',
        dest='vinetto_html_report',
        metavar='PATH',
        type=validate_path,
        required=True,
        help='HTML report previously written by "vinetto".'
    )
    parser.add_argument(
        '--destination',
        dest='dest_path',
        metavar='PATH',
        type=validate_path,
        required=True,
        help='Destination path that files will be copied to.'
    )
    parser.add_argument(
        '--images',
        dest='image_path',
        metavar='PATH',
        type=validate_path,
        required=True,
        nargs='*',
        help='Path to images previously written by "vinetto".'
    )
    parser.add_argument(
        '-v', '--verbose',
        dest='verbose',
        action='store_true',
        default=False,
        help='Increase output verbosity, adds debugging info.'
    )
    args = parser.parse_args()

    LOG_FORMAT = '%(levelname)-6.6s %(message)-s'
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT)
    else:
        logging.basicConfig(level=logging.INFO, format=LOG_FORMAT)

    global log
    log = logging.getLogger(PROGRAM_NAME)

    main(args)
