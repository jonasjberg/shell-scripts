#!/usr/bin/env python
# -*- coding: utf-8 -*-


import argparse
import logging
import time
import sys
import re


def parseCommandLine():
    parser = argparse.ArgumentParser(prog='markdowngrep',
                                     description='Searches markdown-formatted text files for a given pattern/string and, '
                                                 'given a match; returns the heading that contains the text.',
                                     epilog='')

    parser.add_argument('-v', '--verbose',
                        help="Enable verbose output. Increases information printed to stdout.",
                        action='store_true')

    parser.add_argument('pattern',
                        nargs='?',
                        help='Pattern to match.')

    parser.add_argument('-i', '--input',
                        dest='input',
                        nargs='?',
                        help='Files to search.',
                        type=argparse.FileType('r'), default=sys.stdin)

    args = parser.parse_args()
    return args

def processInput(input, pattern):
    log.debug('Got input:' + str(input) + ' and pattern: ' + str(pattern))

    match_linenums = []

    input_data = [line.rstrip() for line in input]

    # https://github.com/lepture/mistune/blob/master/mistune.py
    heading = re.compile(r'^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)')
    lheading = re.compile(r'^([^\n]+)\n *(=|-)+ *(?:\n+|$)')

    for num, line in enumerate(input_data):
        if line.strip():
            if pattern in line:
                log.debug('Found match [{number}] {content}'.format(number=num, content=line.strip()))
                match_linenums.append(num)

                for i in range(0, num):
                    if re.match('^# \w', )


    return


if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(message)s')

    args = parseCommandLine()

    log = logging.getLogger()
    log.info('markdowngrep started')

    startTime = time.time()

    processInput(args.input, args.pattern)

    endTime = time.time()
    duration = endTime - startTime

    logging.info('Elapsed time: ' + str(duration) + ' seconds')
    logging.info('.. DONE!')
