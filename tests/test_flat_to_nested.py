# -*- coding: utf-8 -*-

import re
import unittest

from flat_to_nested import (
    common_substrings,
    try_expand_path_hierarchy
)

# TODO: HACKS!
# TODO: Implement implementation!
# class TestTryExpandPathHierarchy(unittest.TestCase):
#     def test_try_expand_path_hierarchy(self):
#         self.assertIsNotNone(try_expand_path_hierarchy(''))


class TestCommonSubstrings(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.re_substring_seps = re.compile(r'[ _-]')

    def test_two_common_substrings(self):
        # TODO: Implement implementation!
        given = ['foo_bar', 'foo_mjao']
        expect = {'foo': ['foo_bar', 'foo_mjao']}
        actual = common_substrings(given, max_count=1,
                                   separators=self.re_substring_seps)
        self.assertEqual(expect, actual)

    def test_no_common_substrings(self):
        # TODO: Implement implementation!
        given = ['bar_foo', 'mjao_baz']
        expect = dict()
        actual = common_substrings(given, max_count=1,
                                   separators=self.re_substring_seps)
        self.assertEqual(expect, actual)
