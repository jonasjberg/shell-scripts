#!/usr/bin/env bash
#
#     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#      the Free Software Foundation, either version 3 of the License, or
#                     (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                 GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
#     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#                       Written in 2017 by Jonas Sjöberg
#                          http://www.jonasjberg.com
#                        https://github.com/jonasjberg
#
#     A predetermined set of paths are searched for plain text files.
#
#     Indexed search is required for real performance;
#        - Spotlight metadata stores are utilized on Mac OS.
#        - Linux systems use recoll if available.
#
#     The PATTERN query is passed as-is to grep. The search is
#     case-sensitive only if PATTERN contains a capital letter.

set -o pipefail -o errexit -o nounset -o noclobber

LC_ALL=C
NOTES_PATHS=(
    ~/Archive
    ~/Dropbox/txt
    ~/today
)

print_usage()
{
    cat << EOF

USAGE:  ${0##*/} [PATTERN]

A predetermined set of paths are searched for plain text files.
Indexed search is required for performance;

  - Spotlight metadata stores are utilized on Mac OS.
  - Linux systems use recoll if available.

The PATTERN query is passed as-is to grep. The search is
case-sensitive only if PATTERN contains a capital letter.

EOF
}

# Filter files by MIME-type and translate newlines to NULL-bytes.
filter_by_mime_and_zero_terminate()
{
    while IFS='\n' read -r f
    do
        [ -n "$f" ] || continue
        [ -f "$f" ] || continue

        case $(file --mime-type --brief -- "$f") in
            text/plain) echo "$f" ;;
            *) continue ;;
        esac
    done | tr '\n' '\0'
}

# Indexed search is required for real performance. But, Mac OS only.
# Also does not include markdown files in MacOS Sierra v10.12.4 ..
spotlight_search()
{
    command -v mdfind &>/dev/null || return

    mdfind -literal "kMDItemTextContent == \"*$**\"cd" | filter_by_mime_and_zero_terminate
}

# Use "recoll" for indexed searches under Linux, if available.
recoll_search()
{
    command -v recoll >/dev/null 2>&1 || return

    if results="$(recoll -t -b "$*")"
    then
        filter_by_mime_and_zero_terminate <<< "${results//file:\/\/}"
    fi
}

# Used to complement the Spotlight metadata search which doesn't include
# markdown files in MacOS Sierra v10.12.4 ..
find_markdown_files()
{
    for dirpath in "${NOTES_PATHS[@]}"
    do
        [ -d "$dirpath" ] || continue
        find "$dirpath" -xdev -mindepth 1 -type f -name "*.md" -print0
    done
}

# Performs OS-specific search, returns a NULL-terminated list of files.
# Takes any number of arguments as the search query.
find_notes()
{
    case $OSTYPE in
        darwin*)
            # Concatenate streams, executed sequentially.
            ( spotlight_search "$*" ; find_markdown_files "$*" ; ) ;;

        linux*)
            recoll_search "$*" ;;

        *)
            printf 'Unsupported OS-type "%s" --- Exiting ..\n' "$OSTYPE" >&2
            exit 1 ;;
    esac
}


if ! xargs --help | grep -q -- '--no-run-if-empty'
then
    cat >&2 <<EOF

  WARNING:  This script requires a version of xargs that implements
            the GNU extension option '-r', '--no-run-if-empty'.
            Aborting ..                      (TODO: Add workaround)

EOF
    exit 1
fi

# Check arguments and display help text.
if [ $# -eq 0 ]
then
    print_usage
    exit 1
fi

# Check for capital letters in query, "smart-case" re-implemented, badly.
_ignorecase='--ignore-case'
[[ "$*" =~ [A-Z] ]] && _ignorecase=''


# # Concatenate streams, sequential execution.
# # Only the final grep is potentially parallelized.
# ( spotlight_search "$*" ; find_markdown_files "$*" ; ) \
# | xargs -0 -P4 grep --color=always ${_ignorecase} -oHE -- ".{0,40}$*.{0,40}"



# 'find_notes' returns a NULL-terminated list of files that are grepped twice;
# First for surrounding context and then again for coloring the matched parts.

# TODO: Though it it fast enough as-is. Probably should fix the redundancy ..

find_notes "$*" |
xargs --no-run-if-empty -0 -P4 grep --color=never ${_ignorecase} -oHE -- ".{0,40}$*.{0,40}" |
grep --color=always ${_ignorecase} -E -- "$*"


