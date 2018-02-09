#!/usr/bin/env bash
#
# slugify-filename
# ~~~~~~~~~~~~~~~~
# Copyright(c)2015-2018 Jonas Sjöberg
# https://github.com/jonasjberg
#
# Does filename cleanup. I try to use very conservative filenames.
# ASCII, no spaces, braces, brackets, commas, dots, etc.
# This script is meant to automate a lot of tedious renaming.
# I use dashes instead of spaces and underlines for "field" separation.
# For instance: "an-artist_01_a-track.mp3"
# This script also does some substitutions, like replacing
# '@' with 'AT', '&' with 'and', 'C++' with 'Cplusplus', etc.
#_______________________________________________________________________________
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#_______________________________________________________________________________


DRY_RUN=false
SPACE_CHAR='-'
SEPAR_CHAR='_'
GLUE_CHARS='-_'
SAFE_CHARS="${GLUE_CHARS}a-zA-Z0-9"

THIS_SCRIPT_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
EXTERNAL_CONFIG_FILE="${THIS_SCRIPT_PATH}/slugify-filename_config"
if [ -f "$EXTERNAL_CONFIG_FILE" ]
then
    # Using external configuration
    . "$EXTERNAL_CONFIG_FILE"
fi


#_______________________________________________________________________________


msg_error()
{
    printf '[ERROR]: %s\n' "$*"
}

process()
{
    local name="$@"

    name="${name//&/-and-}"             # Replace '&' with '-and-'
    name="${name//\ -and-\ /-and-}"     # Replace ' -and- ' with '-and-'

    name="${name//,\ /\ }"              # Replace comma-space with space
    name="${name//,/${SPACE_CHAR}}"     # Replace comma with 'SPACE_CHAR'
    name="${name//\'/}"                 # Remove single quotes

    # Replace special words
    name="${name//C++/CPP}"
    name="${name//C#/CSharp}"

    if [ -n "$REMOVE_STRINGS" ]
    then
        for string in "${REMOVE_STRING[@]}"
        do
            name="${name//${string}/}"
        done
    fi

    name="${name//@/-AT-}"              # Replace '@' with '-AT-'
    name="${name//\ -AT-\ /-AT-}"       # Replace ' -AT- ' with '-AT-'

    # Replace everything that is not in 'SAFE_CHARS' with 'SPACE_CHAR'
    name="${name//[^${SAFE_CHARS}]/${SPACE_CHAR}}"

    # Replace two or more dashes with a underline, collapse underlines
    name="$(sed -E 's/[-]{2,}/_/g' <<< "$name")"
    name="$(sed -E 's/[_]{2,}/_/g' <<< "$name")"

    # Replace '-_-', '-_' and '_-' with SEPAR_CHAR
    name="${name//-_-/${SEPAR_CHAR}}"
    name="${name//-_/${SEPAR_CHAR}}"
    name="${name//_-/${SEPAR_CHAR}}"

    # Remove any leading and trailing dashes/underlines
    name="$(sed -E 's/^[_-]+//g' <<< "$name")"
    name="$(sed -E 's/[_-]+$//g' <<< "$name")"

    # Replace two or more dashes with a underline, collapse underlines
    name="$(sed -E 's/[-]{2,}/_/g' <<< "$name")"
    name="$(sed -E 's/[_]{2,}/_/g' <<< "$name")"

    # Return value ..
    echo "${name}"
}

main()
{
    # TODO: IMPORTANT! Handle basename separately from the rest of the path.
    name_full="${1}"
    extension="${name_full##*.}"
    name_no_ext="${name_full%.*}"

    if [ -n "$extension" ]
    then
        extension="$(process "${extension}")"
    fi

    if [ -n "$name_no_ext" ]
    then
        name_no_ext="$(process "${name_no_ext}")"
    fi

    if [ -z "$name_no_ext" ]
    then
        # Name without extension is EMPTY --- assume dotfile
        name_no_ext=".${extension}"
        extension=''
    fi

    if [ -n "$extension" ]
    then
        # Extension is *not* NULL ..
        # TODO: Check that it isn't all whitespace?

        if [ "$extension" == "$name_no_ext" ]
        then
            # Extension and full name is the same, remove the extension.
            extension=''
        else
            extension=".${extension}"
        fi
    fi

    if [ -z "$name_no_ext" ]
    then
        # Bail out
        return
    fi

    name_new_full="${name_no_ext}${extension}"

    if [ "$DRY_RUN" == 'true' ]
    then
        printf '%s\n' "$name_new_full"
        return
    else
        mv -n -- "${1}" "${name_new_full}"
    fi
}



# ______________________________________________________________________________
# MAIN ROUTINE EXECUTION STARTS HERE

if [ "$#" -eq "0" ]
then
    msg_error 'Positional arguments missing! At least one is required.'
    exit 1
else
    for arg in "$@"
    do
        main "$arg"
    done
fi

# TODO: Pass back sensible exit status
exit $?

