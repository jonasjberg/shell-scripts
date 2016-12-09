#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#     markdownify-telegram-log.py
#     ===========================
#     Written by Jonas Sjöberg   www.jonasjberg.com  github.com/jonasjberg
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
#
# Telegram log file excerpt:
# ==========================
#
#     Jonas Sjöberg, [21.10.16 18:02]
#     This is the first line of message text.
#     Messages with the same timestamp are separated by an empty line.
#
#
# Desired output format:
# ======================
#
#     #### `2016-10-21 18:02` -- Jonas Sjöberg
#     This is the first line of message text.
#     Seems that a new line means separate message
#     within previous timestamp.
#     Messages with the same timestamp are separated
#     by an empty line.
#
#
# - Header is a level 4 Markdown heading.
# - Header elements are reordered.
# - Text is wrapped at WRAP_WIDTH columns.
# - Trailing whitespace is removed.

import os
import re
import sys
import textwrap

RE_TIMESTAMP = r'\[(\d\d)\.(\d\d)\.(\d\d) (\d\d):(\d\d)\]'
RE_SENDER = r'^(\w+[\s\w]*), '
RE_MESSAGE_HEADER = re.compile(RE_SENDER + RE_TIMESTAMP)
WRAP_WIDTH = 80


def handle_line(textline):
    if not textline.strip():
        return ''
    header_match = RE_MESSAGE_HEADER.match(textline)
    if header_match:
        sender, day, month, year, hour, minute = header_match.groups()
        new_header = '#### `20{y}-{m}-{d} {H}:{M}` -- {n}'.format(y=year,
                                                                  m=month,
                                                                  d=day, H=hour,
                                                                  M=minute,
                                                                  n=sender)
        return new_header
    else:
        return wrap(textline.strip())


def wrap(string):
    return '\n'.join(textwrap.wrap(string, width=WRAP_WIDTH)) + '\n'


def show_usage_and_exit():
    print('Usage: {} [LOGFILE]'.format(sys.argv[0]), file=sys.stderr)
    raise SystemExit(1)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        show_usage_and_exit()

    arg = sys.argv[1]
    if os.path.isfile(arg):
        with open(arg, encoding='utf-8') as f:
            for line in f:
                fixed_line = handle_line(line.rstrip())
                print(fixed_line)
    else:
        print('Not a file: {}'.format(arg), file=sys.stderr)
        show_usage_and_exit()
