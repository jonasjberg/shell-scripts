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


tlib.testcase_begin 'Dry-run mode does not modify file/directory structure 01'
    tlib.tempdirpath_create
    (
        cd "$tempdirpath" || tlib.sanity_check_failure
        tlib.assert_success 'mkdir foo'
        tlib.assert_success '"$dut_filepath" "$tempdirpath"'
        tlib.assert_success '[ -d "$tempdirpath" ]'
        tlib.assert_success '[ -d "${tempdirpath}/foo" ]'
    )
    tlib.tempdirpath_delete
tlib.testcase_end


tlib.testcase_begin 'Dry-run mode does not modify file/directory structure 02'
    tlib.tempdirpath_create
    (
        cd "$tempdirpath" || tlib.sanity_check_failure
        tlib.assert_success 'mkdir bar'
        tlib.assert_success 'mkdir foo'
        tlib.assert_success 'touch bar/baz'
        tlib.assert_success 'touch foo/bar'
        tlib.assert_success '"$dut_filepath" "$tempdirpath"'
        tlib.assert_success '[ -d "${tempdirpath}/bar" ]'
        tlib.assert_success '[ -d "${tempdirpath}/foo" ]'
        tlib.assert_success '[ -f "${tempdirpath}/bar/baz" ]'
        tlib.assert_success '[ -f "${tempdirpath}/foo/bar" ]'
    )
    tlib.tempdirpath_delete
tlib.testcase_end


tlib.testcase_begin 'Dry-run mode does not modify file/directory structure 03'
    tlib.tempdirpath_create
    (
        cd "$tempdirpath" || tlib.sanity_check_failure
        tlib.assert_success 'mkdir bar'
        tlib.assert_success 'mkdir foo'
        tlib.assert_success 'touch bar/bar'
        tlib.assert_success 'touch foo/Foo'
        tlib.assert_success '"$dut_filepath" "$tempdirpath"'
        tlib.assert_success '[ -d "${tempdirpath}/bar" ]'
        tlib.assert_success '[ -d "${tempdirpath}/foo" ]'
        tlib.assert_success '[ -f "${tempdirpath}/bar/bar" ]'
        tlib.assert_success '[ -f "${tempdirpath}/foo/Foo" ]'
    )
    tlib.tempdirpath_delete
tlib.testcase_end


tlib.testcase_begin 'Dry-run mode prints commands applied to file/directory structure 04'
    tlib.tempdirpath_create
    (
        cd "$tempdirpath" || tlib.sanity_check_failure
        tlib.assert_success "Sanity-check: $(declare -p tempdirpath)" '
            [ -d "$tempdirpath" ]
        '

        tlib.assert_success 'mkdir foo'
        tlib.assert_success 'mkdir bar'
        tlib.assert_success 'touch foo/foo'
        tlib.assert_success 'touch bar/baz'

        tlib.assert_success 'dut_stdout="$("$dut_filepath" "$tempdirpath")"'
        tlib.assert_success '[ -n "${dut_stdout:-}" ]'

        tlib.assert_success 'Expected stdout is captured' '
            grep -- "# mv -ni -- \"/tmp/.*_tlib_tempdir/foo/foo\" \"/tmp/.*_tlib_tempdir\" && rmdir -- \"/tmp/.*_tlib_tempdir/foo\"" <<< "$dut_stdout"
        '

        tlib.assert_success '[ -d "${tempdirpath}/bar" ]'
        tlib.assert_success '[ -d "${tempdirpath}/foo" ]'
        tlib.assert_success '[ -f "${tempdirpath}/bar/baz" ]'
        tlib.assert_success '[ -f "${tempdirpath}/foo/foo" ]'
    )
    tlib.tempdirpath_delete
tlib.testcase_end
