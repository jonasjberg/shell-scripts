#!/usr/bin/env bash

# Copyright (c) 2017 jonasjberg
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

set -o noclobber -o nounset -o pipefail


SELF="$(basename "$0")"

# Check arguments, print usage if need be.
if [ "$#" -ne "1" ]
then
    cat >&2 <<EOF

                  -{ git-clone-username-dest.sh }-
                     Written 2017 by jonasjberg
                       github.com/jonasjberg
                         www.jonasjberg.com


  USAGE:  $SELF [REMOTE_URL]

          The remote Git repository at REMOTE_URL is cloned to
          the current directory.  The "username" in the remote
          repository is prepended to the destination directory
          basename.

EXAMPLE:  $SELF 'git@github.com:foo/bar.git'
          Clones the remote repository to 'foo_bar.git'.
          Clones any associated wiki to 'foo_bar_wiki.git'.

  NOTES:  Supported URLs are hardcoded into the script.
          Existing files will not be overwritten.
          Also clones the wiki.  (TODO: add option for this)

EOF
    exit 1
fi


repo_url="$1"
wiki_url="${repo_url/.git/.wiki.git}"

if grep -q 'git@github.com:' <<< "$repo_url"
then
    # GitHub SSH
    repo_dest="${repo_url//git@github.com:}"
elif grep -q 'https://github.com' <<< "$repo_url"
then
    # GitHub HTTPS
    repo_dest="${repo_url//https:\/\/github.com\/}"
elif grep -q 'https://bitbucket.org' <<< "$repo_url"
then
    # Bitbucket HTTPS
    repo_dest="${repo_url//https:\/\/bitbucket.org\/}"
elif grep -q 'git@gitlab.com:' <<< "$repo_url"
then
    # GitLab SSH
    repo_dest="${repo_url//git@gitlab.com:}"
elif grep -q 'https://gitlab.com/.*' <<< "$repo_url"
then
    # GitLab HTTPS
    repo_dest="${repo_url//https:\/\/gitlab.com\//}"
else
    echo "Unsupported source repository URL .. Exiting."
    exit 1
fi


git_clone_no_clobber()
{
    local _url="$1"
    local _dest="$2"

    if [ -e "$_dest" ]
    then
        echo "Skipped \"${_url}\" .."
        echo "Destination exists: \"${_dest}\""
    else
        git clone "$_url" "$_dest"
    fi
}

repo_dest="${repo_dest/\//_}"
git_clone_no_clobber "$repo_url" "$repo_dest"

wiki_dest="${repo_dest/.git/_wiki.git}"
git_clone_no_clobber "$wiki_url" "$wiki_dest"

exit $?

