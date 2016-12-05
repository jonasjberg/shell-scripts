#!/usr/bin/env python
# -*- coding: utf-8 -*-
#     ____________________________________________________________________
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#      the Free Software Foundation, either version 3 of the License, or
#                     (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                 GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#     ____________________________________________________________________


import argparse
import logging
import time
import sys
import re
import pprint
import fileinput


log = logging.getLogger()


def parse_commandline():
    parser = argparse.ArgumentParser(prog='markdowngrep',
        description='Searches markdown-formatted text files for a given '
                    'pattern and displays information on where, as in under '
                    'which heading; that the pattern was found.',
        epilog='')

    parser.add_argument('-v', '--verbose',
                        help="Enable verbose output. Increases information "
                             "printed to stdout.",
                        action='store_true')

    parser.add_argument(dest='pattern',
                        nargs=1,
                        metavar='PATTERN',
                        help='Pattern to match.')

    parser.add_argument(dest='file',
                        nargs='*',
                        type=argparse.FileType('r'), #default=sys.stdin,
                        metavar='FILE',
                        help='Files to search.')

    parser.add_argument('-t', '--top-level',
                        dest='top_level',
                        action='store_true',
                        help='Climb to closest first level heading. Default '
                             'is closest heading, regardless of level.')

    parser.add_argument('-l', '--level',
                        dest='level',
                        type=int,
                        choices=range(1, 6),
                        metavar='N',
                        help='Climb to heading level N.')

    args = parser.parse_args()
    return args


def process_input(input, pattern):
    log.debug('Input: {}'.format(str(input)))
    log.debug('Pattern: {}'.format(str(pattern)))

    input_data = [line.rstrip() for line in input]
    # input_data = input

    matches = []
    for num, line in enumerate(input_data):
        if line.strip():
            if has_match(line, pattern):
            # if pattern in line:
                matches += [{'line': num,
                             'text': line.strip()}]

    for match in matches:
        match['parents'] = find_line_parent_headings(input_data, match['line'])

        log.debug('Found match:')
        for line in pprint.pformat(match).split('\n'):
            log.debug(line)

    return matches


def has_match(line, regexp):
    return line if regexp.search(line) else False


def display_results(matches):
    max_width = 120
    text_width = 20
    for match in matches:
        for parent in match['parents']:

            if len(parent['text']) > text_width:
                text_width = len(parent['text'])

            if args.top_level:
                if parent['level'] == 1:
                    print('{n:04d} "{t}" {m}'.format(n=parent['line'],
                                                     t=parent['text'],
                                                     m=match['text']))
                    break
            else:
                print('{n:04d} "{t}" {m}'.format(n=parent['line'],
                                                 t=parent['text'],
                                                 m=match['text']))
                break


def find_line_parent_headings(textlines, start_line):
    # https://github.com/lepture/mistune/blob/master/mistune.py
    heading = re.compile(r'^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)')

    # Detect Setext-style header. Must be first 2 lines of block.
    # https://github.com/waylan/Python-Markdown/blob/master/markdown
    # /blockprocessors.py
    lheading = re.compile(r'^.*?\n[=-]+[ ]*(\n|$)', re.MULTILINE)

    parents = []
    i = start_line
    while i >= 0:
        sr_h = re.match(heading, textlines[i])
        if sr_h:
            parents += [{'line': i,
                         'level': len(sr_h.group(1)),
                         'text': sr_h.group(2)}]

        sr_lh = re.match(lheading, textlines[i - 1] + '\n' + textlines[i])
        if sr_lh:
            if textlines[i].startswith('='):
                level = 1
            else:
                level = 2
            parents += [{'line': i - 1,
                         'level': level,
                         'text': textlines[i - 1]}]
        i -= 1

    return parents


if __name__ == '__main__':
    args = parse_commandline()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG,
                            format='%(asctime)s %(message)s')
    else:
        logging.basicConfig(level=logging.INFO,
                            format='%(asctime)s %(message)s')

    log.debug('[STARTING]')

    startTime = time.time()

    if args.pattern:
        try:
            pattern = re.compile(args.pattern[0])
        except re.error:
            pattern = args.pattern[0]

    # input = [line.rstrip('\n') for line in args.file]
    input = fileinput.input(args.file)
    results = process_input(input, pattern)
    display_results(results)

    endTime = time.time()
    duration = endTime - startTime

    logging.debug('[FINISHED] Elapsed time: ' + str(duration) + ' seconds')
