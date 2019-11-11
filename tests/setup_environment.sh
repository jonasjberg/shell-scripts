#!/bin/bash

# Exports environment variables used throughout the project.
# Written by Jonas Sjöberg <jonas@jonasjberg.com>


_tstlib_setup_environment()
{
    local _self_relative_filepath
    local _self_absolute_filepath
    _self_relative_filepath="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
    _self_absolute_dirpath="$(
        command dirname -- "$(command readlink -e -- "$_self_relative_filepath")"
    )"

    # Absolute path to the project root directory.
    TSTLIB_PROJECT_ROOT_DIRPATH="$(
        command readlink -e -- "${_self_absolute_dirpath}/.."
    )"

    unset _self_relative_filepath
    unset _self_absolute_dirpath

    if [ ! -d "$TSTLIB_PROJECT_ROOT_DIRPATH" ]
    then
        printf 'ERROR: Bad directory: "%s"\n' "$TSTLIB_PROJECT_ROOT_DIRPATH" >&2
        return 1
    fi

    export TSTLIB_PROJECT_ROOT_DIRPATH
    return 0
}

_tstlib_setup_environment
_tstlib_setup_environment_retval=$?

# Handle either case of this script being sourced or executed.
if [ "$0" != "${BASH_SOURCE[0]}" ]
then
    return $_tstlib_setup_environment_retval
else
    exit $_tstlib_setup_environment_retval
fi
