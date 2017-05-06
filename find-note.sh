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
    printf "USAGE:  ${SELF} [PATTERN]\n\n"
    printf
    printf "A predetermined set of paths are searched for plain text files\n"
    printf "Sportlight metadata stores are utilized on Mac OS.\n"
    printf "The PATTERN query is passed as-is to grep. The search is\n"
    printf "case-sensitive only if PATTERN contains a capital letter.\n"
}

# Filter files by MIME-type and substitutes newlines with NULL-bytes.
filter_by_mime_and_zero_terminate()
{
    while IFS='\n' read f
    do
       case "$(file --mime-type --brief -- "$f")" in
           text/plain) echo "$f" ;;
           *) continue ;;
       esac
    done | perl -p -e 's/\n/\0/;'
}

# Indexed search is required for real performance. But, Mac OS only.
# Also does not include markdown files in MacOS Sierra v10.12.4 ..
spotlight_search()
{
    command -v "mdfind" >/dev/null 2>&1 || return

    mdfind -literal "kMDItemTextContent == \"*$**\"cd" | filter_by_mime_and_zero_terminate
}

# Use "recoll" for indexed searches under Linux, if available.
recoll_search()
{
    command -v "recoll" >/dev/null 2>&1 || return

    recoll -t -b "$*" | sed 's%file://%%g' | filter_by_mime_and_zero_terminate
}

# Used to complement the Spotlight metadata search which doesn't include
# markdown files in MacOS Sierra v10.12.4 ..
find_markdown_files()
{
    find $_search_path -type f -name "*.md" -print0
}

# Performs OS-specific search, returns a NULL-terminated list of files.
# Takes any number of arguments as the search query.
find_notes()
{
    case "$OSTYPE" in
        darwin*)
            # Concatenate streams, executed sequentially.
            ( spotlight_search "$*" ; find_markdown_files "$*" ; ) ;;
        linux*)  recoll_search "$*" ;;
        *) { echo "Unsupported OS; \"${OSTYPE}\" -- Exiting .." ; exit 1 ; } ;;
    esac
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

    _search_path="${note_path} ${_search_path}"
done

echo "Searching: \"${_search_path}\""

# Check for capital letters in query, "smart-case" re-implemented, badly.
_ignorecase='--ignore-case'
[[ "$*" =~ [A-Z] ]] && _ignorecase=''

# # Concatenate streams, sequential execution.
# # Only the final grep is potentially parallelized.
# ( spotlight_search "$*" ; find_markdown_files "$*" ; ) \
# | xargs -0 -P4 grep --color=always ${_ignorecase} -oHE -- ".{0,40}$*.{0,40}"

find_notes "$*" | xargs -0 -P4 grep --color=always ${_ignorecase} -oHE -- ".{0,40}$*.{0,40}"


