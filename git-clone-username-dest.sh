#!/usr/bin/env bash

#                       -{ git-clone-username-dest.sh }-
#                       Written in 2017 by Jonas Sjöberg
#                          http://www.jonasjberg.com
#                        https://github.com/jonasjberg
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



SELF="$(basename "$0")"

# Check arguments, print usage if need be.
if [ "$#" -ne "1" ]
then
    cat >&2 <<EOF

Usage:  $SELF [REMOTE_URL]
The remote Git repository at REMOTE_URL will be cloned to the current
directory.  The username is prepended to the destination directory.

Supported URLs:  GitHub, Bitbucket and GitLab.

EOF
    exit 1
fi


url="$1"

if grep -q 'git@github.com:' <<< "$url"
then
    # GitHub SSH
    _dest="${url//git@github.com:}"
    _dest="${_dest/\//_}"
elif grep -q 'https://github.com' <<< "$url"
then
    # GitHub HTTPS
    _dest="${url//https:\/\/github.com\/}"
    _dest="${_dest/\//_}"
elif grep -q 'https://bitbucket.org' <<< "$url"
then
    # Bitbucket HTTPS
    _dest="${url//https:\/\/bitbucket.org\/}"
    _dest="${_dest/\//_}"
elif grep -q 'git@gitlab.com:' <<< "$url"
then
    # GitLab SSH
    _dest="${url//git@gitlab.com:}"
    _dest="${_dest/\//_}"
elif grep -q 'https://gitlab.com/.*' <<< "$url"
then
    # GitLab HTTPS
    _dest="${url//https:\/\/gitlab.com\//}"
    _dest="${_dest/\//_}"
else
    echo "Unsupported source repository URL .. Exiting."
    exit 1
fi

if [ -e "$_dest" ]
then
    echo "Destination directory exists: \"${_dest}\" .. Exiting."
    exit 1
fi


git clone "$url" "$_dest"

exit $?

