#!/bin/bash

# First written 2019-12-13 by jonas@jonasjberg.com
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Does fast-forward pulls of the currently checked out branch from all remotes
# in seqence.  If all fast-forward pulls succeed, the same branch is pushed to
# the same sequence of remotes in order.

set -o errexit -o pipefail -o noclobber -o nounset


print_error_message()
{
    printf 'ERROR: %s. Exiting..\n' "$*" >&2
}


if ! command -v git &> /dev/null
then
    print_error_message 'This script requires Git'
    exit 127
fi

if ! command git rev-parse --is-inside-work-tree &>/dev/null
then
    print_error_message 'This is not a Git repository'
    exit 1
fi

if ! command git diff-files --quiet &>/dev/null
then
    print_error_message 'The working tree has unstaged changes'
    exit 1
fi

if ! command git diff-index --quiet --cached HEAD &>/dev/null
then
    print_error_message 'The repository has staged, uncommitted changes'
    exit 1
fi


_CHECKED_OUT_BRANCH="$(command git rev-parse --abbrev-ref HEAD)"
readonly _CHECKED_OUT_BRANCH

declare -a _REMOTES
while IFS=$'\n' read -r _stdout_line
do
    _REMOTES+=("$_stdout_line")
done < <(command git remote | LC_ALL=C command sort)
readonly _REMOTES


for _remote in "${_REMOTES[@]}"
do
    if ! command git pull --ff-only -- "$_remote" "$_CHECKED_OUT_BRANCH"
    then
        printf '\nABORTING! Failed fast-forward-only pull from remote: %s\n' "$_remote" >&2
        exit 1
    fi
done


for _remote in "${_REMOTES[@]}"
do
    if ! command git push -- "$_remote" "$_CHECKED_OUT_BRANCH"
    then
        printf '\nABORTING! Failed push to remote: %s\n' "$_remote" >&2
        exit 1
    fi
done


exit 0
