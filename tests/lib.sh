#!/bin/bash

# Utilities for end-to-end/system tests using arbitrary shell commands.
# Written by Jonas Sjöberg <jonas@jonasjberg.com>

set -o pipefail -o errexit -o noclobber -o nounset


readonly EXITSTATUS_TESTRESULT_PASS=0
readonly EXITSTATUS_TESTRESULT_FAIL=1
readonly EXITSTATUS_ERROR=2

if [ -n "${TERM:-}" ] && command -v tput &>/dev/null
then
    _bold="$(tput bold)" || _bold=''
    COLOR_RED="$(tput setaf 1)${_bold}"
    COLOR_GREEN="$(tput setaf 2)${_bold}"
    COLOR_BLUE="$(tput setaf 4)${_bold}"
    COLOR_BLUE_DIM="$(tput setaf 4)"
    COLOR_RESET="$(tput sgr0)"
    unset _bold
else
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_BLUE=''
    COLOR_BLUE_DIM=''
    COLOR_RESET=''
fi
readonly COLOR_RED
readonly COLOR_GREEN
readonly COLOR_BLUE
readonly COLOR_BLUE_DIM
readonly COLOR_RESET


_on_assertion_failure()
{
    local _fail_filename="${BASH_SOURCE[2]}"
    local _fail_linenumber="${BASH_LINENO[1]}"
    printf '\n\n%sASSERTION FAILED%s at file:line %s:%s\n' \
        "$COLOR_RED" "$COLOR_RESET" "$_fail_filename" "$_fail_linenumber"
    exit $EXITSTATUS_TESTRESULT_FAIL
}

_msg_failed()
{
    [ "$1" = 'SUPPRESS' ] && return
    printf '%sFAIL:%s %s\n' "$COLOR_RED" "$COLOR_RESET" "$*"
}

_msg_passed()
{
    [ "$1" = 'SUPPRESS' ] && return
    printf '%sPASS:%s %s\n' "$COLOR_GREEN" "$COLOR_RESET" "$*"
}

_print_traceback()
{
    local i funcname source_linenum source_file
    local _stacksize="${#FUNCNAME[@]}"

    declare -a collected_stacktrace=()

    for (( i=1; i<$_stacksize; i++ ))
    do
        funcname="${FUNCNAME[$i]}"
        [ -z "${funcname:-}" ] && funcname='[main]'

        source_file="${BASH_SOURCE[$i]}"
        [ -z "${source_file:-}" ] && source_file='[non-file]'

        source_linenum="${BASH_LINENO[$(( i - 1 ))]}"
        collected_stacktrace+=("SOURCEFILE $source_file:$source_linenum WITHIN $funcname")
    done

    # NOTE: Since the tests are evaluated (eval foo) with their output
    # redirected to /dev/null, this must be executed in a subshell in
    # order to pipe stderr (not suppressed by redirection) to column.
    printf '\nTRACEBACK (from most recently called):\n' >&2
    (
        for stackframe in "${collected_stacktrace[@]}"
        do
            printf '%s\n' "$stackframe"
        done
    ) | column -t -s' ' >&2
}

tlib.sanity_check_failure()
{
    printf 'CRITICAL: Internal sanity check failed!\n' >&2
    _print_traceback
    exit $EXITSTATUS_ERROR
}

# Both primary assertion functions 'tlib.assert_failure()' and
# 'tlib.assert_success()' can be passed either one or two arguments.
#
#       tlib.assert_failure (DESCRIPTION) EXPRESSION_TO_EVALUATE
#
# The DESCRIPTION argument is optional.
# This should describe what the assertion tests in a human-readable way,
# to be displayed when running the tests.
# When omitted, the evaluated expression is used as the description.
#
#   Example:
#
#       tlib.assert_failure '[ foo = bar ]'
#
#   Example with description:
#
#       tlib.assert_failure 'strings should not match' '[ foo = bar ]'
#
# Passing a "DESCRIPTION" of 'SUPPRESS' will prevent the assertion from being
# displayed when running the tests.
# This can be used to set up some state prior to interacting with the device
# under test.
#
#   Example of hidden (silent) assertion:
#
#       tlib.assert_failure 'SUPPRESS' '[ foo = bar ]'
#
# Note that all of the above also applies to the 'tlib.assert_success'
# function.

tlib.assert_failure()
{
    local _message
    local _command

    if [ $# -eq 2 ]
    then
        _message="$1"
        _command="$2"
    else
        [ $# -eq 1 ] || tlib.sanity_check_failure

        # Strip leading whitespace from each line.
        _message="$(command sed -e 's/^[[:space:]]*//g' <<< "$1")"
        _command="$1"
    fi

    if eval "$_command" &>/dev/null
    then
        _msg_failed "$_message"
        _on_assertion_failure
    else
        _msg_passed "$_message"
    fi
}

tlib.assert_success()
{
    local _message
    local _command

    if [ $# -eq 2 ]
    then
        _message="$1"
        _command="$2"
    else
        [ $# -eq 1 ] || tlib.sanity_check_failure

        # Strip leading whitespace from each line.
        _message="$(command sed -e 's/^[[:space:]]*//g' <<< "$1")"
        _command="$1"
    fi

    if eval "$_command" &>/dev/null
    then
        _msg_passed "$_message"
    else
        _msg_failed "$_message"
        _on_assertion_failure
    fi
}

tlib.testcase_begin()
{
    local _self_basename
    _self_basename="$(command basename -- "$0")"
    printf '\n%sFile: %s%s\n' "$COLOR_BLUE_DIM" "$_self_basename" "$COLOR_RESET"
    printf '%sCase: %s%s\n' "$COLOR_BLUE" "$1" "$COLOR_RESET"
}

tlib.testcase_end()
{
    :
}

tlib.tempdirpath_create()
{
    tempdirpath="$(
        command mktemp --directory --suffix _tlib_tempdir
    )" || tlib.sanity_check_failure
}

tlib.tempdirpath_delete()
{
    # shellcheck disable=SC2015
    [ -d "${tempdirpath:-}" ] && command rm -rf -- "$tempdirpath" || : # no-op
}

trap tlib.tempdirpath_delete EXIT
