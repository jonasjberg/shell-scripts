#!/bin/bash
set -o noclobber -o nounset -o pipefail

# git-pull-recursively.sh
# ~~~~~~~~~~~~~~~~~~~~~~~
# Written by Jonas Sjöberg in 2015
# Rewritten by Jonas Sjöberg 2017-05-03
# Updated by Jonas Sjöberg 2018-01-16
# Updated by Jonas Sjöberg 2021-02-15

# Does a recursive search for ".git" directories, enters the parent directory
# within a subshell and performs a bunch of tests for unstaged/uncommitted
# changes. If the tests pass, the reposity is updated using git pull if no
# merge is needed ('--ff-only' flag).

# Recursively search and perform "git pull" on all found repositories here.
SEARCH_PATH="${1:-${HOME}/dev/sourcecode/}"
IGNORE_LIST_BASENAME='git-pull-recursively.ignores'


if [ -n "${TERM:-}" ] && command -v tput >/dev/null
then
    COLOR_RED="$(tput setaf 1)"
    COLOR_GREEN="$(tput setaf 2)"
    COLOR_YELLOW="$(tput setaf 3)"
    COLOR_RESET="$(tput sgr0)"
else
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_RESET=''
fi

SELF_DIRNAME="$(readlink -- "$(dirname -- "$0")")"
IGNORE_LIST_PATH="${SELF_DIRNAME}/${IGNORE_LIST_BASENAME}"

declare -i count_skipped=0
declare -i count_failed=0
declare -i count_total=0
declare -i count_success=0

log_colorlabel()
{
    local -r _color="$1" ; shift
    local -r _label="$1" ; shift

    printf '%s[%s]%s %s\n' "$_color" "$_label" "$COLOR_RESET" "$*"
}

log_warn()
{
    log_colorlabel "$COLOR_YELLOW" 'WARNING' "$1"
    shift

    while test "$#" -gt "0"
    do
        printf "          %s\n" "$1" 1>&2
        shift
    done
}

log_skip()
{
    log_warn "$*"
    count_skipped="$((count_skipped + 1))"
}

log_fail()
{
    log_colorlabel "$COLOR_RED" 'FAILURE' "$*"
    count_failed="$((count_failed + 1))"
}

log_ok()
{
    log_colorlabel "$COLOR_GREEN" 'SUCCESS' "$*"
    count_success="$((count_success + 1))"
}


if [ ! -d "$SEARCH_PATH" ]
then
    log_colorlabel "$COLOR_RED" 'FAILURE' "Invalid path: \"${SEARCH_PATH}\""
    log_colorlabel "$COLOR_RED" 'FAILURE' 'Variable "SEARCH_PATH" must be set before running this script'
    exit 1
fi


while IFS= read -r -d '' _repo_gitdir
do
    count_total="$((count_total + 1))"

    _repo_worktree="$(dirname -- "$_repo_gitdir")"
    _repo_basename="$(basename -- "$_repo_worktree")"

    if [ -f "$IGNORE_LIST_PATH" ]
    then
        if grep --fixed-strings --file="$IGNORE_LIST_PATH" -- <<< "$_repo_basename" &>/dev/null
        then
            log_skip "Ignored repository: \"${_repo_basename}\""
            continue
        fi
    fi

    if ! git --work-tree "$_repo_worktree" --git-dir "$_repo_gitdir" status &>/dev/null
    then
        log_fail "Not a Git repository: \"${_repo_worktree}\""
        continue
    fi

    if ! git --work-tree "$_repo_worktree" --git-dir "$_repo_gitdir" diff-files --quiet
    then
        log_skip 'The Repository working tree has changes that could be staged' \
            "Skipping repository: \"${_repo_basename}\""
        continue
    fi

    if ! git --work-tree "$_repo_worktree" --git-dir "$_repo_gitdir" diff-index --quiet --cached HEAD
    then
        log_skip 'Repository has staged (uncommitted) changes' \
            "Skipping repository: \"${_repo_basename}\""
        continue
    fi

    if echo git --work-tree "$_repo_worktree" --git-dir "$_repo_gitdir" pull --ff-only --quiet
    then
        log_ok "Updated repository: \"${_repo_basename}\""
    else
        log_fail "pull failed for repository: \"${_repo_basename}\""
    fi

    # Random pause between requests ..
    sleep $(((RANDOM % 3) + 1))

done < <(find "$SEARCH_PATH" -xdev -type d -name '.git' -print0)


duration="$(
    printf '%02d hours %02d minutes %02d seconds' \
        $((SECONDS / 3600)) $((SECONDS % 3600 / 60)) $((SECONDS % 60))
)"

printf '\n\n'
log_colorlabel "$COLOR_GREEN" 'FINISHED' "Elapsed time: ${duration}"
printf '           Found Total : %d\n' "$count_total"
printf '           Updated     : %d\n' "$count_success"
printf '           Skipped     : %d\n' "$count_skipped"
printf '           FAILED      : %d\n' "$count_failed"

if [ "$count_failed" -gt "0" ]
then
    exit 1
else
    exit 0
fi
