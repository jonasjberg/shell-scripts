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


from unittest import TestCase

from markdowngrep import find_line_parent_headings


class TestMarkdownGrep(TestCase):
    def setUp(self):
        self.sampletext = '''
Title
=====
First paragraph.

* List item 1
* List item 2

## First second level heading
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed augue nunc, ornare sit amet blandit quis, sagittis eget risus.


### First third level heading
Class aptent taciti sociosqu ad litora torquent per conubia nostra,
per inceptos himenaeos. Sed iaculis viverra mattis.

Second second level heading
---------------------------
Aenean sagittis nulla libero, sit amet feugiat diam molestie et.


### Second third level heading
#### First fourth level heading
Nullam non erat velit. Donec ullamcorper varius auctor.


#### Second fourth level heading
Suspendisse feugiat urna sed erat cursus finibus.


# Final level one heading
Lorem ipsum dolor sit amet, consectetur adipiscing elit.

'''

        # Note that Title is on line 1.

        self.sampletext = self.sampletext.rsplit('\n')

    def test_find_line_parent_headings(self):
        # text = [line.rstrip('\n') for line in self.sampletext]
        self.assertCountEqual(find_line_parent_headings(self.sampletext, 3),
                              [{'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 6),
                              [{'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 10),
                              [{'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 15),
                              [{'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 19),
                              [{'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 22),
                              [{'line': 22, 'level': 3,
                                'text': 'Second third level heading'},
                               {'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 23),
                              [{'line': 23, 'level': 4,
                                'text': 'First fourth level heading'},
                               {'line': 22, 'level': 3,
                                'text': 'Second third level heading'},
                               {'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 25),
                              [{'line': 23, 'level': 4,
                                'text': 'First fourth level heading'},
                               {'line': 22, 'level': 3,
                                'text': 'Second third level heading'},
                               {'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 28),
                              [{'line': 27, 'level': 4,
                                'text': 'Second fourth level heading'},
                               {'line': 23, 'level': 4,
                                'text': 'First fourth level heading'},
                               {'line': 22, 'level': 3,
                                'text': 'Second third level heading'},
                               {'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 32),
                              [{'line': 31, 'level': 1,
                                'text': 'Final level one heading'},
                               {'line': 27, 'level': 4,
                                'text': 'Second fourth level heading'},
                               {'line': 23, 'level': 4,
                                'text': 'First fourth level heading'},
                               {'line': 22, 'level': 3,
                                'text': 'Second third level heading'},
                               {'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])

        self.assertCountEqual(find_line_parent_headings(self.sampletext, 33),
                              [{'line': 31, 'level': 1,
                                'text': 'Final level one heading'},
                               {'line': 27, 'level': 4,
                                'text': 'Second fourth level heading'},
                               {'line': 23, 'level': 4,
                                'text': 'First fourth level heading'},
                               {'line': 22, 'level': 3,
                                'text': 'Second third level heading'},
                               {'line': 17, 'level': 2,
                                'text': 'Second second level heading'},
                               {'line': 13, 'level': 3,
                                'text': 'First third level heading'},
                               {'line': 8, 'level': 2,
                                'text': 'First second level heading'},
                               {'line': 1, 'level': 1, 'text': 'Title'}])
