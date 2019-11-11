#!/bin/bash

# Runs all tests.
# Written by Jonas Sjöberg <jonas@jonasjberg.com>

set -o pipefail -o errexit -o noclobber -o nounset


# If the environment has not been initialized yet, try to locate the setup
# script from the Git repository root and use it to setup the environment.
if [ -z "${TSTLIB_PROJECT_ROOT_DIRPATH:-}" ]
then
    if _gitroot_dirpath="$(command git rev-parse --show-toplevel)"
    then
        _setupscript_filepath="${_gitroot_dirpath}/tests/setup_environment.sh"
        [ -r "$_setupscript_filepath" ] && source "$_setupscript_filepath"
    fi
fi


if [ ! -d "${TSTLIB_PROJECT_ROOT_DIRPATH:-}" ]
then
    command cat <<'EOF'

ERROR: Environment variable "$TSTLIB_PROJECT_ROOT_DIRPATH"
       must be set to the project root directory path; I.E.,
       the directory containing the '.git' directory.

EOF
    exit 1
fi


(
    # Required because the tests use relative paths when sourcing other files.
    cd "${TSTLIB_PROJECT_ROOT_DIRPATH}/tests" || exit 1

    source ./lib.sh

    command find . -xdev -maxdepth 1 -type f -name 'test_*.sh' -print0 |
    command sort --zero-terminated |
    while IFS= read -r -d '' test_filepath
    do
        if eval "$test_filepath"
        then
            :
        else
            printf '\n\n------------------------------------------\n'
            printf 'Summary results: %sAT LEAST ONE TEST FAILED!%s\n' "$COLOR_RED" "$COLOR_RESET"
            exit 1
        fi
    done

    printf '\n\n----------------------------------\n'
    printf 'Summary results: %sALL TESTS PASSED!%s\n' "$COLOR_GREEN" "$COLOR_RESET"
)


exit 0
