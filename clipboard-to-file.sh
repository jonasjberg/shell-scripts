#!/usr/bin/env bash
#                       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                              clipboard-to-file
#                       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                    Copyright (C) 2015-2017 Jonas Sjöberg
#                        https://github.com/jonasjberg
#                              www.jonasjberg.com
#
#              Create a file with the contents of the clipboard.
#              Intended for use as a Thunar custom action.
#              USAGE: clipboard-to-file [PATH] [FILE]
#                     PATH - Create the file in this directory
#                     FILE - Optional name of the file.
#                            (Defaults to "${DEFAULT_FILENAME}")
#     ____________________________________________________________________
#
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


set -e                                                  # exit on first error
#set -x                                                 # debug mode

PROGNAME="$(basename $0)"
timestamp="$(date +%FT%H%M%S)"
DEFAULT_FILENAME="xclipboard_${timestamp}.txt"


msg_error()
{
    printf '[ERROR] %s\n' "$*" >&2
}


if ! command -v "xclip" >/dev/null
then
    echo "ERROR: Unable to execute xclip. Exiting .."
    exit 127
fi

if [ $# -eq 0 ]
then
    echo "ERROR: Positional argument is missing!"
    echo "USAGE: ${PROGNAME} [PATH] [FILE]"
    echo "       PATH - Create the file in this directory"
    echo "       FILE - Optional name of the file."
    echo "              (Defaults to \"${DEFAULT_FILENAME}\")"
    exit 1
fi

[ -e "$1" ] || { msg_error "Does not exist: \"${1}\" .."  ; exit 1 ; }
[ -d "$1" ] || { msg_error "Not a directory: \"${1}\" .." ; exit 1 ; }

dest="${1}/${2:-$DEFAULT_FILENAME}"

[ -e "$dest" ] && { msg_error "Would be overwritten: \"${dest}\" .." ; exit 1 ; }

# Have xclip output the clipboard (X selection) contents to $dest
xclip -out > "$dest"

# Test for zero file size, delete file if true. Could happen if the
# clipboard is empty or contains something unsuitable for stdout.
if [ ! -s "$dest" ]
then
    rm -v -- "$dest"
fi

exit $?