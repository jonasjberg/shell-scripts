#!/usr/bin/env bash

#                -~==================================~-
#                 CONGREP --- "Context-sensitive" grep
#                    Written by @jonasjberg in 2018
#                 --~~============================~~--
#
#        This work is free.  You can redistribute and/or modify
#        it under the terms of the Do What The Fuck You Want To
#        Public License. See http://www.wtfpl.net/ for details.
# ______________________________________________________________________
#
# This script looks for a file named $CONFIG_BASENAME (defined below) in
# the current working directory and uses its contents as grep options.
# If the file is not in the current working directory but this directory
# is within a git repository, the root directory of the repository is
# also checked for a $CONFIG_BASENAME file.
# Any positional arguments passed to this script are added after any
# options read from the file.
# If no file is found, this script effectively acts as a alias for grep.
#
# Example usage:
#
#   $ cat .local_grep_flags
#   -ir --color=always --exclude-dir={.git,.idea}
#   $ congrep -E 'fo[oO]+'
#
# Which runs: 'grep -ir --color=always --exclude-dir={.git,.idea} -E 'fo[oO]+'


set -o noclobber -o pipefail -o errexit

SELF_BASENAME="$(basename "$0")"
CONFIG_BASENAME='.local_grep_flags'


declare -a grepflags

read_flags_from_config_in_cwd()
{
    # readarray options
    #
    #   -t  Remove a trailing newline from each line read.
    #   -n  Copy at most count lines.  If count is 0, all lines are copied.
    #
    readarray -t -n 1 grepflags < "$CONFIG_BASENAME"
}

has_local_config_in_cwd() { [ -f "$CONFIG_BASENAME" ] ; }
cwd_is_within_git_repository() { git status >/dev/null 2>&1 ; }
cd_to_git_repository_root() { cd "$(git rev-parse --show-toplevel)" ; }


if has_local_config_in_cwd
then
    read_flags_from_config_in_cwd
elif cwd_is_within_git_repository
then
    cd_to_git_repository_root && has_local_config_in_cwd \
        && read_flags_from_config_in_cwd && cd - >/dev/null
fi

if [ -n "$grepflags" ]
then
    # Prevent expansion of metacharacters like '{' by running with eval.
    eval grep "${grepflags[@]}" "$@"
else
    # Direct pass-through.
    grep "$@"
fi
