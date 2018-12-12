#!/usr/bin/env bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set -o errexit -o nounset -o pipefail -o noclobber

readonly SELF_BASENAME="$(basename -- "$0")"

readonly SPACE_CHAR='-'
readonly SEPAR_CHAR='_'
readonly GLUE_CHARS='-_'
readonly SAFE_CHARS="${GLUE_CHARS}a-zA-Z0-9"


src="$1"
if [ $# -ne 1 ]
then
    printf 'USAGE:  %s [DIRECTORY_PATH]\n' "$SELF_BASENAME" >&2
    exit 1
fi

if [ ! -d "$src" ]
then
    printf '%s: [ERROR] Argument "%s" is not a directory\n' \
           "$SELF_BASENAME" "${src}" >&2
    exit 1
fi


# Generate a filename from the source directory name ..
name="$src"

# Replace everything that is not in 'SAFE_CHARS' with 'SPACE_CHAR'
name="${name//[^${SAFE_CHARS}]/${SPACE_CHAR}}"

# Replace two or more dashes with a underline, collapse underlines
name="$(sed -r 's/[-]{2,}/_/g' | sed -r 's/[_]{2,}/_/g' <<< "$name")"

# Replace what probable was some kind of separator with $SEPAR_CHAR
name="${name//-_-/${SEPAR_CHAR}}"
name="${name//-_/${SEPAR_CHAR}}"
name="${name//_-/${SEPAR_CHAR}}"

# Remove any dashes and underlines if first or last in name
name="$(sed -r 's/^[_-]+//g' | sed -r 's/[_-]+$//g' <<< "$name")"


# Create archive ..
timestamp="$(date +%F)"
tar -zcvf "${name}_${timestamp}.tar.gz" "$src"

exit $?
