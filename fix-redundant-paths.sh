#!/usr/bin/env bash

# Copyright(c)2017-2019 <jonas@jonasjberg.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

set -o noclobber -o nounset -o pipefail -o errexit


print_usage()
{
    command cat <<EOF

Usage:  "$(basename -- "$0")" [PATH]...

Where PATH is one or more paths to files or directories.
Directories are recursively searched for files to process.

Processing starts with finding "matches" to be "fixed" by testing
if the file basename (lower-cased, without extension) is the same
as the basename of the parent directory (lower-cased).
If there are additional files stored in the same directory as the
file, the file is skipped and no longer considered a match.

For instance, if the following paths was processed;

    /tmp/
    ├── bar
    │   ├── bar.jpg
    │   └── foo.tar
    └── foo
        └── foo.txt

Only the last file "foo.txt" is considered a match. The basename
of the parent directory "foo" equals the file basename "foo.txt"
_after stripping the extension_, leaving "foo".
Also, the parent directory "/tmp/foo" contains only a single file
and would be left empty after having moved "/tmp/foo/foo.txt" to
"/tmp/foo.txt".

Finally, commented shell commands to rectify the situation are
written to stdout:

    # mv -ni -- "/tmp/foo/foo.txt" "/tmp/" && rmdir -- "/tmp/foo"

Which, if executed, would result in the following:

    /tmp/
    ├── bar
    │   ├── bar.jpg
    │   └── foo.tar
    └── foo.txt


NOTE: Nothing is written to disk!

EOF
# TODO: Write to disk!
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
