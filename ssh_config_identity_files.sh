#!/bin/bash
# Checks whether SSH private key files specified in ~/.ssh/config exist.
set -o errexit -o noclobber -o nounset -o pipefail


[[ -e ~/.ssh/config ]] || {
    printf 'SKIP: SSH configuration file "~/.ssh/config" does not exist..\n'
    exit 0
}


declare -i exitstatus=0

command grep -Po '(?<=IdentityFile\s).*' ~/.ssh/config |
while IFS=$'\n' read -r identityfile
do
    identityfile_expanded_homepath="$(identityfile/#\~/$HOME}"
    if [[ -e $identityfile_expanded_homepath  ]]
    then
        printf 'PASS: %s (%s)\n' \
            "$identityfile" "$identityfile_expanded_homepath"
    else
        printf 'FAIL: File does not exist: %s (%s)\n' \
            "$identityfile" "$identityfile_expanded_homepath" >&2
        exitstatus=13
    fi
done


exit "$exitstatus"
