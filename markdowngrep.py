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


    input_data = [line.rstrip() for line in input]

    # https://github.com/lepture/mistune/blob/master/mistune.py
    heading = re.compile(r'^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)')
    lheading = re.compile(r'^([^\n]+)\n *(=|-)+ *(?:\n+|$)')

    for num, line in enumerate(input_data):
        if line.strip():
            if pattern in line:
                log.debug('Found match: [{number}] {content}'.format(number=num, content=line.strip()))

                # Now go backwards, starting from the matching line.
                i = num
                while i > 0:
                    # log.debug('Searching line {}'.format(i))
                    sr_h = re.match(heading, input_data[i])
                    if sr_h:
                        log.info('Found heading: [{heading}] ... {content}'.format(heading=sr_h.group(2), content=pattern))
                        break
                    i -= 1

                # TODO: FIX THIS HACKY MESS!
                i = num
                while i > 0:
                    sr_lh = re.match(lheading, input_data[i - 1])
                    if sr_lh:
                        log.info('Found heading: [{heading}] ... {content}'.format(heading=sr_lh.group(1), content=pattern))
                        break
                    i -= 1
    return


if __name__ == '__main__':
    args = parseCommandLine()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(message)s')
    else:
        logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

    log = logging.getLogger()
    log.info('markdowngrep started')

    startTime = time.time()

    processInput(args.input, args.pattern)

    endTime = time.time()
    duration = endTime - startTime

    logging.info('Elapsed time: ' + str(duration) + ' seconds')
    logging.info('.. DONE!')
