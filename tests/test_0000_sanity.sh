#!/bin/bash

# Initial prerequisite tests and sanity checking.
# Written by Jonas Sjöberg <jonas@jonasjberg.com>

set -o pipefail -o noclobber -o nounset


# TODO: Refer to this file with an absolute path, relative to this script.
source ./lib.sh


tlib.testcase_begin 'Sanity-check the executing shell'
    tlib.assert_success 'Environment variable $BASH_VERSION is defined' '
        [ -n "${BASH_VERSION:-}" ]
    '
    tlib.assert_success 'Require Bash version v4.*' '
        (
            case $BASH_VERSION in
                4.*) return 0 ;;
                  *) return 1 ;;
            esac
        )
    '
tlib.testcase_end


tlib.testcase_begin 'Sanity-check internal assertion functions, etc.'
    tlib.assert_success '[ -n "${TSTLIB_PROJECT_ROOT_DIRPATH:-}" ]'
    tlib.assert_success 'command true'
    tlib.assert_failure 'command false'
    tlib.assert_success '[ "foo" = "foo" ]'
    tlib.assert_failure '[ "foo" = "bar" ]'
tlib.testcase_end


tlib.testcase_begin 'Sanity-check internal handling of temporary directories'
    tlib.assert_success 'Initially undefined' '
        [ -z "${tempdirpath:-}" ]
    '

    tlib.tempdirpath_create
    tlib.assert_success 'Created directory exists' '
        [ -d "$tempdirpath" ]
    '
    tlib.assert_success 'Created directory is readable' '
        [ -r "$tempdirpath" ]
    '
    tlib.assert_success 'Created directory contents are readable' '
        [ -x "$tempdirpath" ]
    '
    tlib.assert_success "Sanity-check: $(declare -p tempdirpath)" '
        declare -p tempdirpath
    '

    tlib.tempdirpath_delete
    tlib.assert_success 'Deleted directory does not exist' '
        [ ! -d "$tempdirpath" ]
    '
    tlib.assert_success 'Deleted directory is not readable' '
        [ ! -r "$tempdirpath" ]
    '
    tlib.assert_success "Sanity-check: $(declare -p tempdirpath)" '
        declare -p tempdirpath
    '
tlib.testcase_end


tlib.testcase_begin 'Prerequisites are met'
    tlib.assert_success 'command -v cat'
    tlib.assert_success 'command -v dirname'
    tlib.assert_success 'command -v git'
    tlib.assert_success 'command -v ln'
    tlib.assert_success 'command -v mktemp'
    tlib.assert_success 'command -v python'
    tlib.assert_success 'command -v python3'
    tlib.assert_success 'command -v readlink'
    tlib.assert_success 'command -v realpath'
    tlib.assert_success 'command -v rm'
    tlib.assert_success 'command -v sed'
    tlib.assert_success 'command -v wc'

    tlib.assert_success 'python --version'
    tlib.assert_success 'python --version 2>&1 | grep -q "Python 2\.[67]\."'
tlib.testcase_end
