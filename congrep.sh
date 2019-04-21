#!/usr/bin/env bash

#                -~==================================~-
#                 CONGREP --- "Context-sensitive" grep
#                   Written by @jonasjberg 2018-2019
#                 --~~============================~~--
#
#        This work is free.  You can redistribute and/or modify
#        it under the terms of the Do What The Fuck You Want To
#        Public License. See http://www.wtfpl.net/ for details.
# ______________________________________________________________________
#
# This script looks for a file named $congrep_config_basename in the
# current working directory and uses its contents as grep options.
#
# WARNING:  SECURITY RISK! FILE CONTENTS ARE EVAL'd -- USE WITH CAUTION!
#
# If the file is not in the current working directory but this directory
# is within a git repository, the root directory of the repository is
# also checked for a $congrep_config_basename file.
# Any positional arguments passed to this script are added after any
# options read from the file.
# If no file is found, this script effectively acts as a alias for grep.
#
#
# Example configuration file contents:
#
#   $ cat .local_grep_flags
#   -ir --exclude-dir={.git,.idea}
#
# Example invocation:
#
#   $ congrep -E 'fo[oO]+'
#
# Which would effectively execute:
#
#   $ grep -ir --exclude-dir={.git,.idea} -E 'fo[oO]+'
# ______________________________________________________________________

set -o noclobber -o pipefail -o errexit

readonly congrep_config_basename='.congrep_config'


declare -a grepflags

read_flags_from_config_in_cwd()
{
    # readarray options
    #
    #   -t  Remove a trailing newline from each line read.
    #   -n  Copy at most count lines.  If count is 0, all lines are copied.
    #
    readarray -t -n 1 grepflags < "$congrep_config_basename"
}

has_local_config_in_cwd() { [ -f "$congrep_config_basename" ] ; }
cwd_is_within_git_repository() { git status >/dev/null 2>&1 ; }
cd_to_git_repository_root() { cd "$(git rev-parse --show-toplevel)" ; }


if has_local_config_in_cwd
then
    read_flags_from_config_in_cwd
elif cwd_is_within_git_repository
then
    if cd_to_git_repository_root
    then
        has_local_config_in_cwd && read_flags_from_config_in_cwd
        cd - >/dev/null
    fi
fi

if [ -n "$grepflags" ]
then
    # Prevent expansion of metacharacters like '{' by running with eval.
    eval grep "${grepflags[@]}" "$@"
else
    # Direct pass-through.
    grep "$@"
fi
