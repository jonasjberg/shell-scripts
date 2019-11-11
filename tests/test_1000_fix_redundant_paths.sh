#!/bin/bash

# Written by Jonas Sjöberg <jonas@jonasjberg.com>

set -o pipefail -o noclobber -o nounset


# TODO: Refer to this file with an absolute path, relative to this script.
source ./lib.sh


tlib.testcase_begin 'DUT is readable and executable'
    tlib.assert_success 'TSTLIB_PROJECT_ROOT_DIRPATH is set' '
        [ -n "$TSTLIB_PROJECT_ROOT_DIRPATH" ]
    '
    tlib.assert_success 'TSTLIB_PROJECT_ROOT_DIRPATH is a directory' '
        [ -d "$TSTLIB_PROJECT_ROOT_DIRPATH" ]
    '

    dut_filepath="${TSTLIB_PROJECT_ROOT_DIRPATH}/fix-redundant-paths.sh"
    tlib.assert_success 'DUT is readable' '
        [ -r "$dut_filepath" ]
    '
    tlib.assert_success 'DUT is executable' '
        [ -r "$dut_filepath" ]
    '
tlib.testcase_end


tlib.testcase_begin 'Smoke-tests'
    tlib.assert_success 'Exits successfully when not passed any arguments' '
        "$dut_filepath"
    '
    tlib.assert_success 'Exits successfully when passed non-existant arguments' '
        "$dut_filepath" -h
    '
    tlib.assert_success 'Exits successfully when passed non-existant arguments' '
        "$dut_filepath" --help
    '
tlib.testcase_end
