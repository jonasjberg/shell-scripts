#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#     DATEDELTA         Jonas Sjoberg
#     ~~~~~~~~~         https://github.com/jonasjberg
#                       jomeganas@gmail.com
#
#     Calculates and displays the difference between
#     two dates as the number of years, months and days.
#
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

import argparse
import sys
from datetime import datetime

try:
    from dateutil.relativedelta import relativedelta
except ImportError:
    raise SystemExit('Missing required module "dateutil" --- Aborting ..')


def str_to_datetime(string):
    digits = ''.join([c for c in string if c.isdigit()])
    try:
        dt = datetime.strptime(digits, '%Y%m%d')
    except ValueError:
        return None
    else:
        return dt


def main():
    parser = argparse.ArgumentParser(
        prog='datedelta',
        description='Display time between two dates in number of years, months and days',
        epilog='The second date defaults to the current date if left unspecified'
    )
    parser.add_argument(
        dest='dates',
        metavar='ISOLIKE_DATE',
        nargs='+',
        help='Dates should be written as "YYYYmmdd". '
             'Everything except digits is removed before parsing. '
             'This means most formats similar to ISO 8601 are accepted.'
    )

    opts = parser.parse_args()

    d1 = str_to_datetime(opts.dates[0])
    try:
        d2 = str_to_datetime(opts.dates[1])
    except IndexError:
        d2 = datetime.today().replace(hour=0, minute=0, second=0, microsecond=0)

    if not d1 or not d2:
        parser.print_usage()
        sys.exit(1)

    delta = relativedelta(d2, d1)
    print('1st date: {}'.format(d1.strftime('%Y-%m-%d')))
    print('2nd date: {}'.format(d2.strftime('%Y-%m-%d')))
    print('   DELTA: {} years, {} months, {} days'.format(delta.years, delta.months, delta.days))


if __name__ == '__main__':
    main()
