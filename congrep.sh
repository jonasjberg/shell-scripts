#!/usr/bin/env sh

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
#
# Any positional parameters passed to this script are added after any
# options read from the file. If no file is found, this script
# effectively acts as a alias for grep.
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

ConGrep='.local_grep_flags'
UseColor='--color=auto'
#UseColor='--color=never'

if [ -f "$ConGrep" ] && [ -r "$ConGrep" ]; then
    GetFlags(){
        awk -SP '
            {
                if(NR!~/^#+/){
                    sub(/#+.*$/, "")
                    for(FC=1; FC<=NF; FC++){
                        if($FC~/^-.*$/){
                            printf("%s ", $FC)
                        }
                    }
                }
            }
        ' "$1"
    }

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        TopLVL=`git rev-parse --show-toplevel 2>&-`

        if [ -n "$TopLVL" ]; then
            eval grep $UseColor `GetFlags "$TopLVL/$ConGrep"` "$@"
            exit $?
        else
            exit 7
        fi
    else
        eval grep $UseColor `GetFlags "$ConGrep"` "$@"
        exit $?
    fi
else
    grep $UseColor "$@"
    exit $?
fi
