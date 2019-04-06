#!/usr/bin/env bash

# Copyright (c) 2017-2019 jonasjberg
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

set -o noclobber -o nounset -o pipefail -o errexit


print_usage()
{
    cat >&2 <<EOF

Usage:  "$(basename -- "$0")" [PATH_TO_SEARCH]

Where PATH_TO_SEARCH is the path to an existing file
or a directory to recursively search for files.
Files whose basename (without any extension) equals the
basename of the parent directory are considered "matches".

Commented shell commands that would rectify the situation is
printed for every "matched" file _if_ the matched directory
only contains a single file.
For instance, given the following paths:

    /tmp/redundancy/
    ├── bar
    │   ├── bar.jpg
    │   ├── baz.tar
    │   └── foo.csv
    └── foo
        └── foo.txt

Only the last file satisfies the condition; the basename
of the dirname "foo" equals the file basename "foo.txt"
_after stripping the extension_, leaving "foo".
And the directory "/tmp/redundancy/foo" would be empty after
moving "/redundancy/foo/foo.txt" to "/redundancy/foo/bar.txt".

This would result in the following output:

    # mv -ni -- "/tmp/redundancy/foo/foo.txt" "/tmp/redundancy" && rmdir -- "/tmp/redundancy/foo"

Which, if executed, would result in the following:

    /tmp/redundancy/
    ├── bar
    │   ├── bar.txt
    │   ├── baz.txt
    │   └── foo.txt
    └── foo.txt

NOTE:  Nothing is written to disk! Commands are printed to stdout.

EOF
}

find_redundant_basename_dirname()
{
    while IFS= read -r -d '' _abspath
    do
        [ -f "$_abspath" ] || {
            printf 'Expected a file. Got: "%s"\n' "$_abspath" >&2
            continue
        }

        _dirname="$(dirname -- "$_abspath")"
        [ -d "$_dirname" ] || {
            printf 'Expected a directory. Got: "%s"\n' "$_dirname" >&2
            continue
        }

        _basename="$(basename -- "$_abspath")"
        _basename_no_ext="${_basename%.*}"
        _dirbasename="$(basename -- "$_dirname")"

        if [ "$_basename_no_ext" == "$_dirbasename" ]
        then
            _dest="$(dirname -- "$(dirname -- "$_abspath")")"

            if [ "$(find "$_dirname" -mindepth 1 -maxdepth 1 | wc -l)" -ne "1" ]
            then
                # Skip directories containing more than the matched file.
                continue
            fi

            printf '# mv -ni -- "%s" "%s" && rmdir -- "%s"\n' "$_abspath" "$_dest" "$_dirname"
        fi
    done
}


if ! man xargs | col -b | grep -- '--no-run-if-empty' >/dev/null 2>&1
then
    cat >&2 <<EOF

  WARNING:  This script requires a version of xargs that implements
            the GNU extension option '-r', '--no-run-if-empty'.
            Aborting ..                      (TODO: Add workaround)

EOF
    exit 1
fi

if [ $# -eq 0 ]
then
    print_usage
    exit 0
fi

for arg in "$@"
do
    if [ ! -e "$arg" ]
    then
        printf 'Not a file or directory: "%s"\n' "$arg"
        continue
    fi

    if [ -d "$arg" ]
    then
        find_redundant_basename_dirname < <(
            find "$arg" -xdev -type f -print0 |
            sort --zero-terminated |
            xargs --no-run-if-empty -0 realpath --zero --canonicalize-existing
        )
    elif [ -f "$arg" ]
    then
        find_redundant_basename_dirname < <(
            realpath --zero --canonicalize-existing -- "$arg"
        )
    fi
done
