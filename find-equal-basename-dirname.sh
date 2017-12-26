#!/usr/bin/env bash

# Copyright (c) 2017 jonasjberg
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

set -o noclobber -o nounset -o pipefail -o errexit


SELF_BASENAME="$(basename "$0")"

print_usage()
{
    cat >&2 <<EOF


    Usage:  ${SELF_BASENAME} [PATH_TO_SEARCH]

    Where PATH_TO_SEARCH is the path to an existing file
    or a directory to recursively search for files.
    Files whose basename (without any extension) equals the
    basename of the parent directory are considered "matches".

    Commented shell commands that could rectify the situation is
    printed for every "matched" file.

    For instance, given the following paths:

        /foo/bar/foo.txt
        /foo/bar/baz.txt
        /foo/bar/bar.txt

    Only the last file satisfies the condition; the basename
    of the dirname ("bar") equals the basename of the file
    ("bar.txt") _without_ the extension ("bar").
    This would result in the following output:

        # mv -nvi -- "/foo/bar/bar.txt" "/foo" && rmdir -v -- "/foo/bar"

    NOTE:  No files are touched on disk!

EOF
}

find_redundant_basename_dirname()
{
    while IFS= read -r -d '' filepath
    do
        # _abspath="$(realpath -e -- "$filepath")"
        _abspath="$filepath"
        [ -f "$_abspath" ] || continue

        _basename="$(basename -- "$_abspath")"
        _basename_no_ext="${_basename%.*}"
        _dirname="$(dirname -- "$_abspath")"
        _dirbasename="$(basename -- "$_dirname")"

        if [ "$_basename_no_ext" == "$_dirbasename" ]
        then
            _dest="$(dirname -- "$(dirname -- "$_abspath")")"
            [ -d "$_dirname" ] || { printf 'Expected a directory. Got: "%s"\n' "$_dirname" >&2 ; continue ; }
            [ -f "$_abspath" ] || { printf 'Expected a file. Got: "%s"\n' "$_abspath" >&2 ; continue ; }

            printf '# mv -nvi -- "%s" "%s" && rmdir -v -- "%s"\n' "$_abspath" "$_dest" "$_dirname"
        fi
    done
}


if [ "$#" -eq "0" ]
then
    print_usage
    exit 0
fi

for arg in "$@"
do
    if [ -d "$arg" ]
    then
        find_redundant_basename_dirname < <(find "$arg" -xdev -type f -print0 | sort -z | xargs -0 realpath -e -z)
    elif [ -f "$arg" ]
    then
        find_redundant_basename_dirname < <(realpath -e -z -- "$arg")
    else
        printf 'Not a file or directory: "%s"\n' "$arg"
    fi
done

