#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# DATEDELTA     Jonas Sjoberg
# ~~~~~~~~~     https://github.com/jonasjberg
#               jomeganas@gmail.com
#
# Calculates and displays the difference between two dates as the number of
# years, months and days.

import argparse
import sys
from datetime import datetime

try:
    from dateutil.relativedelta import relativedelta
except ImportError:
    print('Please install "dateutil" first.')
    sys.exit(1)


parser = argparse.ArgumentParser(prog='datedelta',
                                 description='Show the difference between two '
                                             'dates in years, months and days.',
                                 epilog='The second date defaults to the '
                                        'current date if left unspecified.')
parser.add_argument(dest='dates',
                    metavar='date',
                    nargs='+',
                    help='Date written as "YYYY-mm-dd", with separators such '
                         'as "-" being optional.')
args = parser.parse_args()


def str_to_datetime(string):
    digits = ''
    for char in string:
        if char.isdigit():
            digits += char
    try:
        dt = datetime.strptime(digits, '%Y%m%d')
    except ValueError:
        return None
    else:
        return dt


d1 = str_to_datetime(args.dates[0])
try:
    d2 = str_to_datetime(args.dates[1])
except IndexError:
    d2 = datetime.today().replace(hour=0, minute=0, second=0, microsecond=0)

if not d1 or not d2:
    parser.print_usage()
    sys.exit(1)

delta = relativedelta(d2, d1)
print('1st date: {}'.format(d1.strftime('%Y-%m-%d')))
print('2nd date: {}'.format(d2.strftime('%Y-%m-%d')))
print('   DELTA: {} years, {} months, {} days'.format(delta.years,
                                                      delta.months,
                                                      delta.days))
