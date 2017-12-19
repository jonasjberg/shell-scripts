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

set -o noclobber -o nounset -o pipefail


SELF="$(basename "$0")"

# Check arguments, print usage if need be.
if [ "$#" -ne "1" ]
then
    cat >&2 <<EOF

  Usage:  $SELF [REMOTE_URL]

          The remote Git repository at REMOTE_URL is cloned to
          the current directory.  The "username" in the remote
          repository is prepended to the destination directory
          basename.

Example:  $SELF 'git@github.com:foo/bar.git'
          Clone the remote to a local directory 'foo_bar.git'.

   NOTE:  Supported URLs are hardcoded into the script.
          Existing files will not be overwritten.

EOF
    exit 1
fi


repo_url="$1"

if grep -q 'git@github.com:' <<< "$repo_url"
then
    # GitHub SSH
    repo_dest="${repo_url//git@github.com:}"
    repo_dest="${repo_dest/\//_}"
elif grep -q 'https://github.com' <<< "$repo_url"
then
    # GitHub HTTPS
    repo_dest="${repo_url//https:\/\/github.com\/}"
    repo_dest="${repo_dest/\//_}"
elif grep -q 'https://bitbucket.org' <<< "$repo_url"
then
    # Bitbucket HTTPS
    repo_dest="${repo_url//https:\/\/bitbucket.org\/}"
    repo_dest="${repo_dest/\//_}"
elif grep -q 'git@gitlab.com:' <<< "$repo_url"
then
    # GitLab SSH
    repo_dest="${repo_url//git@gitlab.com:}"
    repo_dest="${repo_dest/\//_}"
elif grep -q 'https://gitlab.com/.*' <<< "$repo_url"
then
    # GitLab HTTPS
    repo_dest="${repo_url//https:\/\/gitlab.com\//}"
    repo_dest="${repo_dest/\//_}"
else
    echo "Unsupported source repository URL .. Exiting."
    exit 1
fi

if [ -e "$repo_dest" ]
then
    echo "Destination directory exists: \"${repo_dest}\" .. Exiting."
    exit 1
fi


git clone "$repo_url" "$repo_dest"

exit $?

