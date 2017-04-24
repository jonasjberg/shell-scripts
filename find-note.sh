#!/usr/bin/env bash

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
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# set -x

# Make sure regex comparison works reliably independent of current locale.
LC_ALL=C

SELF="$(basename "$0")"

NOTES_PATH=("${HOME}/Dropbox/txt" "${HOME}/today" "${HOME}/Archive")

print_usage()
{
    printf "USAGE:  ${SELF} [DIR] [FILE(s)]\n\n"
    printf 'Arguments should be either files or directories.\n'
    printf 'Directories are searched *non-recursively*; "sub-directories" are ignored.\n'
    printf 'Files whose names matches "[0-9]+.webm" are searched for metadata.\n'
    printf 'If suitable metadata is found the files are renamed from the results.\n'
}


if [ "$#" -eq "0" ]
then
    print_usage
    exit 1
fi


_search_path=""
for note_path in "${NOTES_PATH[@]}"
do
    [ -d "$note_path" ] || continue
    [ -x "$note_path" ] || continue  # Check that directory can be searched.

    echo "note_path OK: \"${note_path}\""
    _search_path="${note_path} ${_search_path}"
done

echo "_search_path: \"${_search_path}\""

# Check for capital letters in query, "smart-case" re-implemented, badly.
_ignorecase='--ignore-case'
[[ "$*" =~ [A-Z] ]] && _ignorecase=''

# grep options used:
#
#     -H     Always print filename headers with output lines.
#     -m, --max-count  Behaviour differs between GNU and BSD versions.
#                      GNU grep counts per file, BSD grep counts all as one..
#
grep --color=always ${_ignorecase} --recursive -H  \
     --exclude-dir={.git} --include={*.md,*.txt}   \
     --extended-regexp --only-matching             \
     -- ".{0,40}$*.{0,40}" $_search_path
    #| less --RAW-CONTROL-CHARS --chop-long-lines

#     -- "$*"                                                    \
