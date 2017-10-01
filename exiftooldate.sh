#!/usr/bin/env bash

#   exiftooldate          Copyright (C) 2016-2017 Jonas Sjöberg
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


if ! command -v "exiftool" >/dev/null 2>&1
then
    printf "This script requires \"exiftool\" to run.\n"
    exit 127
fi

if [ "$#" -eq "0" ]
then
    printf "Usage: $(basename "$0") [FILE]..\n"
    exit 1
fi

for arg in "$@"
do
    [ -e "$arg" ] || continue
    [ -r "$arg" ] || continue
    [ -d "$arg" ] && continue

    printf '\nExtracted date/time-information for: "%s"\n' "$arg"
    exiftool -short -e -a -s -G1 "-*date*" "-*year*" "$arg" \
    | awk '{printf "%-15.15s %20.20s %-s %-s %s\n", $1, $2, $3, $4, $5}'
done

exit $?

