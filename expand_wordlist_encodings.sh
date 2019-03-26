#!/bin/bash

# expand_wordlist_encodings.sh
# Written 2019-03-22 by jonasjberg
# Intended to generate data forensics wordlists.
# Converts a UTF-8 text file to all possible successful
# iconv transcodings; which are then de-duplictated,
# sorted and printed to stdout.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This work is free.  You can redistribute and/or modify
# it under the terms of the Do What The Fuck You Want To
# Public License. See http://www.wtfpl.net/ for details.
# ______________________________________________________

set -o errexit -o nounset -o noclobber

readonly EXIT_STATUS_FAILURE=1
readonly EXIT_STATUS_SUCCESS=0


if ! command -v iconv &>/dev/null
then
    printf '[CRITICAL] This script requires "iconv" .. Exiting!\n'
    exit $EXIT_STATUS_FAILURE
fi


declare -a encodings_list
encodings_list=(
    $(iconv --list)
)
# declare -p encodings_list

print_usage_to_stdout()
{
    cat << EOF

  USAGE:  $(basename -- "$0") [SOURCE_FILEPATH]

  Where SOURCE_FILEPATH is the path to a file whose contents
  will be converted to all encodings supported by "iconv".

  All generated output is then concatenated, deduplictated
  and printed to stdout.

EOF
}

if [ $# -ne 1 ]
then
    print_usage_to_stdout
    exit $EXIT_STATUS_FAILURE
fi


source_filepath="$1"
if [[ ! -f "$source_filepath" ]]
then
    print_usage_to_stdout
    exit $EXIT_STATUS_FAILURE
fi

case "$(command file --mime-type --brief -- "$source_filepath")" in
    text/*) ;;
         *) printf '[ERROR] Expected a text file. Got "%s"\n' "$source_filepath"
            exit $EXIT_STATUS_FAILURE ;;
esac


if ! temp_dirpath="$(command mktemp --directory --quiet)"
then
    printf 'Unable to create temporary directory!\n'
    exit $EXIT_STATUS_FAILURE
fi

if [[ ! -d "$temp_dirpath" ]]
then
    printf 'Expected temporary directory at path "%s"\n' "$temp_dirpath"
    exit $EXIT_STATUS_FAILURE
fi


delete_temporary_files()
{
    [[ -d "$temp_dirpath" ]] && command rm -rf -- "$temp_dirpath"
}

delete_temporary_files_and_exit_unsuccessfully()
{
    delete_temporary_files
    exit $EXIT_STATUS_FAILURE
}

trap delete_temporary_files_and_exit_unsuccessfully INT TERM


for enc in ${encodings_list[@]}
do
    _enc_slug="${enc//[^a-zA-Z0-9_-]/}"
    _destpath="${temp_dirpath}/${_enc_slug}.partial"
    [[ -e "$_destpath" ]] && continue

    if ! command iconv --to-code="$enc" --from-code='UTF-8//' -o "$_destpath" \
        < "$source_filepath" &>/dev/null
    then
        # Delete partial files left behind at failure.
        [[ -f "$_destpath" ]] && command rm -- "$_destpath"
    fi
done

command cp -n -- "$source_filepath" "${temp_dirpath}/source.partial"


command find "${temp_dirpath}" -maxdepth 1 -type f -name '*.partial' -print0 |
    xargs -0 cat | LC_ALL=C sort -u


delete_temporary_files
exit $EXIT_STATUS_SUCCESS
