#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#  Copyright (c) 2017 Jonas Sjöberg
#  http://www.jonasjberg.com
#  https://github.com/jonasjberg
#
#  Edits the clipboard contents with default text editor.
#  Opens a text editor with the current clipboard contents and stores the
#  possibly edited text back in the clipboard when the text editor is closed.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import shutil
import sys
import os
import logging
import subprocess

PROGRAM_NAME = os.path.basename(__file__)

#
#
#    *****************************************
#    NOTICE!
#    THIS PROGRAM IS STILL A WORK IN PROGRESS!
#    ***       NOT  READY  FOR  USE        ***
#    *****************************************
#
#

# Make sure required commands are available.
if not shutil.which('mediainfo'):
    print('This program requires "{c}" to run. Make sure that "{c}" is '
          'installed and executable.'.format(c='mediainfo', file=sys.stderr))
    raise SystemExit(1)



def show_usage_and_exit():
    print('Usage: {} [FILE1] [FILE2]'.format(PROGRAM_NAME), file=sys.stderr)
    raise SystemExit(1)


def exec_mediainfo(opts, path):
    assert opts is not None
    assert path is not None

    if not isinstance(opts, list):
        raise TypeError('opts must be a list')
    if not isinstance(path, str):
        raise TypeError('path must be a string')

    try:
        cmd = ['mediainfo'] + opts + [path]
        # cmd = ['mediainfo', '--Inform=Video;%Format%\n%Format_Profile%\n%', '/tank/media/tvseries/X-Files/S01/The-X-Files_S01E00_Pilot.avi']
        logging.debug('exec_mediainfo OPTS: "{}"'.format(','.join(opts)))
        logging.debug('exec_mediainfo PATH: "{}"'.format(str(path)))
        logging.debug('exec_mediainfo Executing: "{}"'.format(str(cmd)))
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        stdout = e.output
        retval = e.returncode
        logging.error('[ERROR] {c} returned exit code {c} and the following'
                      ' standard output:'.format(p='mediainfo', c=retval))
        logging.error(str(line) for line in stdout)
    else:
        return output.decode('utf-8')


def get_mediafile_info(path):
    # def _info_video(path):
    #     _raw = exec_mediainfo(['--Inform="Video;%Format%'], path)
    #     #print(str(_raw))
    #     return _raw

    #     info = {}
    #     for line in _raw.splitlines():
    #         print(str(line))
    #         key, value = line.split(': ')
    #         info[key] = value
    #    return info
    # return(_info_video(path))

    info = exec_mediainfo([], path)
    if not info:
        logging.info('Unable to extract information for: "{}"'.format(path))
        return False

    logging.debug('Extracted information for file: "{}"'.format(path))
    return info



if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog=PROGRAM_NAME,
        description='Compares the output of "mediainfo" for the specified files.',
        epilog='Written by Jonas Sjöberg in 2017.'
    )

    parser.add_argument(dest='files',
                        metavar='FILE',
                        nargs=2,
                        help='Media files to compare.')
    parser.add_argument('-v', '--verbose',
                        dest='verbose',
                        action='store_true',
                        help='Increase output verbosity, adds debug information.')
    args = parser.parse_args()

    LOG_FORMAT = '%(asctime)s %(levelname)-6.6s %(message)-s'
    LOG_FORMAT_VERBOSE = '%(asctime)s.%(msecs)03d %(levelname)-6.6s %(message)-s'
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT_VERBOSE,
                            datefmt='%Y-%m-%d %H:%M:%S')
    else:
        logging.basicConfig(level=logging.INFO, format=LOG_FORMAT,
                            datefmt='%Y-%m-%d %H:%M:%S')

    for file in args.files:
        if not os.path.isfile(file):
            print('Not a file: "{}"'.format(file, file=sys.stderr))
            sys.exit(1)
        if not os.access(file, os.R_OK):
            print('Missing read permission: "{}"'.format(file, file=sys.stderr))
            sys.exit(1)

    info1 = get_mediafile_info(args.files[0])
    #info2 = get_mediafile_info(args.files[1])

    logging.debug('Information extracted by mediainfo:')
    for line in info1.splitlines():
        logging.debug(line)
