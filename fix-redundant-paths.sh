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
Files whose basename (without any extension, lower-cased)
equals the basename of the parent directory (lower-cased)
are considered "matches" to be fixed.

Commented shell commands that would rectify the situation is
printed for every "matched" file _if_ the matched directory
only contains a single file.
For instance, given the following paths:

    /tmp/redundancy/
    ├── bar
    │   ├── bar.jpg
    │   └── foo.tar
    └── foo
        └── foo.txt

Only the last file satisfies the condition; the basename
of the dirname "foo" equals the file basename "foo.txt"
_after stripping the extension_, leaving "foo".
And the directory "/tmp/redundancy/foo" would be empty after
moving "/redundancy/foo/foo.txt" to "/redundancy/foo.txt".

This would result in the following output:

    # mv -ni -- "/tmp/redundancy/foo/foo.txt" "/tmp/redundancy" &&
        rmdir -- "/tmp/redundancy/foo"

Which, if executed, would result in the following:

    /tmp/redundancy/
    ├── bar
    │   ├── bar.jpg
    │   └── foo.tar
    └── foo.txt

NOTE:  Nothing is written to disk! Commands are printed to stdout.

EOF
}

find_redundant_basename_dirname()
{
    while IFS= read -r -d '' _file_abspath
    do
        [ -f "$_file_abspath" ] || {
            printf 'Expected a file. Got: "%s"\n' "$_file_abspath" >&2
            continue
        }

        _file_pardir_abspath="$(dirname -- "$_file_abspath")"
        [ -d "$_file_pardir_abspath" ] || {
            printf 'Expected a directory. Got: "%s"\n' "$_file_pardir_abspath" >&2
            continue
        }

        # Normalize the file basename by stripping the file extension and making it lower-case.
        _file_basename="$(basename -- "$_file_abspath")"
        _normalized_file_basename="$(tr '[:upper:]' '[:lower:]' <<< ${_file_basename%.*})"
        unset _file_basename

        # Normalize the parent directory basename by making it lower-case.
        _file_pardir_basename="$(basename -- "$_file_pardir_abspath")"
        _normalized_file_pardir_basename="$(tr '[:upper:]' '[:lower:]' <<< $_file_pardir_basename)"
        unset _file_pardir_basename

        if [ "$_normalized_file_basename" == "$_normalized_file_pardir_basename" ]
        then
            if [ "$(find "$_file_pardir_abspath" -mindepth 1 -maxdepth 1 | wc -l)" -ne "1" ]
            then
                # Skip directories containing more than the matched file.
                continue
            fi

            _destpath="$(dirname -- "$_file_pardir_abspath")"
            printf '# mv -ni -- "%s" "%s" && rmdir -- "%s"\n' "$_file_abspath" "$_destpath" "$_file_pardir_abspath"
        fi
    done
}


if [ $# -eq 0 ]
then
    print_usage
    exit 0
fi

for arg in "$@"
do
    if existing_abspath="$(readlink --canonicalize-existing -- "$arg")"
    then
        if [ -d "$existing_abspath" ]
        then
            find_redundant_basename_dirname < <(
                find "$existing_abspath" -xdev -type f -print0 |
                sort --zero-terminated
            )
        elif [ -f "$existing_abspath" ]
        then
            printf '%s\0' "$existing_abspath" | find_redundant_basename_dirname
        fi
    fi
done
