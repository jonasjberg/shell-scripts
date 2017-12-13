#!/usr/bin/env bash

# git-pull-recursively.sh
# ~~~~~~~~~~~~~~~~~~~~~~~
# Written by Jonas Sjöberg in 2015
# Rewritten by Jonas Sjöberg 2017-05-03

# Does a recursive search for ".git" directories, enters the parent directory
# within a subshell and performs a bunch of tests for unstaged/uncommitted
# changes. If the tests pass, the reposity is updated using git pull if no
# merge is needed ('--ff-only' flag).

set -o noclobber -o nounset -o pipefail

C_RED="$(tput setaf 1)"
C_GREEN="$(tput setaf 2)"
C_YELLOW=$(tput setaf 3)
C_RESET="$(tput sgr0)"

# Recursively search and perform "git pull" on all found repositories here.
SEARCH_PATH="${HOME}/dev/sourcecode/"
IGNORE_LIST_BASENAME='git-pull-recursively.ignores'

SELF_DIRNAME="$(realpath -e "$(dirname "$0")")"
IGNORE_LIST_PATH="${SELF_DIRNAME}/${IGNORE_LIST_BASENAME}"

count_skipped=0
count_failed=0
count_total=0
count_success=0


log_warn()
{
    printf "${C_YELLOW}[WARNING]${C_RESET} %s\n" "$1"
    shift

    while test "$#" -gt "0"
    do
        printf "          %s\n" "$1" 1>&2
        shift
    done
}

log_fail()
{
    printf "${C_RED}[FAILURE]${C_RESET} %s\n" "$*" 1>&2
    count_failed="$((count_failed + 1))"
}

log_skip()
{
    log_warn "$*"
    count_skipped="$((count_skipped + 1))"
}

log_ok()
{
    printf "${C_GREEN}[SUCCESS]${C_RESET} %s\n" "$*" 1>&2
    count_success="$((count_success + 1))"
}



if [ ! -d "$SEARCH_PATH" ]
then
    echo "Invalid path: \"${SEARCH_PATH}\"" 1>&2
    exit 1
fi


START_DIR="$(pwd)"

while IFS= read -r -d '' repo
do
    count_total="$((count_total + 1))"

    _repo_dir="$(realpath -- "${repo}/..")"
    if ! cd "${_repo_dir}"
    then
        log_fail "Unable to cd to directory: \"${_repo_dir}\""
        continue
    fi


    _name="$(basename "$(pwd)")"
    if [ -f "$IGNORE_LIST_PATH" ]
    then
        if grep --fixed-strings --file="$IGNORE_LIST_PATH" -- <<< "$_name"
        then
            log_skip "Ignored repository: \"${_name}\""
            continue
        fi
    fi

    if ! ( git status 2>&1 ) >/dev/null
    then
        log_fail "Not a git repository: \"${_repo_dir}\""
        continue
    fi

    if ! git diff-files --quiet
    then
        log_skip "The Repository working tree has changes that could be staged" \
                 "Skipping repository: \"${_name}\""
        continue
    fi

    if ! git diff-index --quiet --cached HEAD
    then
        log_skip "Repository has staged (uncommitted) changes" \
                 "Skipping repository: \"${_name}\""
        continue
    fi

    # if git diff-index --quiet HEAD
    # then
    #     echo "The combination of index and tracked files in the working tree are changed with respect to HEAD"
    # fi


    if git pull --ff-only --quiet
    then
        log_ok "Successfully updated repository: \"${_name}\""
    else
        log_fail "pull failed for repository: \"${_name}\""
    fi

    # Random pause between requests ..
    sleep $(( ( RANDOM % 3 )  + 1 ))

done < <(find "$SEARCH_PATH" -xdev -type d -name ".git" -print0)


cd "$START_DIR"

duration="$(printf '%02d hours %02d minutes %02d seconds' \
            $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60)))"
printf "\n\n${C_GREEN}[FINISHED]${C_RESET} Elapsed time: ${duration}\n"

printf "           Found Total : %d\n" "$count_total"
printf "           Updated     : %d\n" "$count_success"
printf "           Skipped     : %d\n" "$count_skipped"
printf "           FAILED      : %d\n" "$count_failed"

if [ "$count_failed" -gt "0" ]
then
    exit 1
else
    exit 0
fi

