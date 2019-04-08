#!/usr/bin/env bash

#   exiftooldate          Copyright (C) 2016-2018 Jonas Sjöberg
#   ~~~~~~~~~~~~          https://github.com/jonasjberg
#                         http://www.jonasjberg.com
#
#   Get date/time-information from file(s) using exiftool.
#   Obviously requires exiftool to be installed.
#
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

readonly self_basename="$(basename -- "$0")"


if ! command -v exiftool &>/dev/null
then
    printf '%s Missing required executable "exiftool" ..\n' "$self_basename"
    exit 127
fi

if [ $# -eq 0 ]
then
    printf 'Usage: %s [FILE]...\n' "$self_basename"
    exit 1
fi


declare -i exitcode

for arg in "$@"
do
    [ -r "$arg" ] || continue
    [ -d "$arg" ] && continue

    printf '\nExtracted date/time-information for "%s":\n' "$arg"

    if exiftool_stdout="$(exiftool -short -duplicates -groupNames1 "-*date*" "-*year*" "$arg")"
    then
        awk '{printf "%-15.15s %20.20s %-s %-s %s\n", $1, $2, $3, $4, $5}' <<< "$exiftool_stdout"
    else
        exitcode=1
    fi
done


exit $exitcode
