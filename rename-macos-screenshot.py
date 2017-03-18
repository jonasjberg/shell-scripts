#!/usr/bin/env python
# -*- coding: utf-8 -*-

#  rename-macos-screenshot.py
#  ==========================
#  Copyright (c) 2017 Jonas Sjöberg
#  http://www.jonasjberg.com
#  https://github.com/jonasjberg
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

import sys
import re
import os

# Example filename to rename:   Screen Shot 2017-03-18 at 04.41.59.jpg
MACOS_SCREENSHOT_REGEX = r'Screen Shot ([12]\d{3}-[01]\d-[0123]\d) at ([012]\d.[012345]\d.[012345]\d)\.png'
ADD_FILETAGS = 'screenshot macbookpro'

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: {} [FILE [FILE ...]]'.format(sys.argv[0]))
        sys.exit(1)
    else:
        for arg in sys.argv[1:]:
            if not os.path.isfile(arg):
                continue
            else:
                if not os.access(arg, os.R_OK):
                    continue

                head, tail = os.path.split(os.path.abspath(arg))

                matches = re.search(MACOS_SCREENSHOT_REGEX, tail)
                if matches:
                    new_name = '{date}T{time} -- {tags}.png'.format(date=matches.group(1),
                                                                    time=matches.group(2).replace('.', ''),
                                                                    tags=ADD_FILETAGS)
                    dest_path = os.path.join(head, new_name)
                    if os.path.isfile(dest_path):
                        # Abort: Path already exist and would be overwritten.
                        continue
                    else:
                        os.rename(os.path.abspath(arg), dest_path)

        sys.exit(0)
