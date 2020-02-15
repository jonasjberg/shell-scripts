#!/usr/bin/env bash

# Copyright (c) 2017 jonasjberg
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

set -o noclobber -o nounset -o pipefail

readonly SELF_BASENAME="$(basename -- "$0")"


if [ "$#" -ne "1" ]
then
    cat <<EOF

                 .-{ git-clone-username-dest.sh }-.
                         written 2017--2019
                        github.com/jonasjberg
                         www.jonasjberg.com


  USAGE:  $SELF_BASENAME [REMOTE_URL]

          The remote Git repository at REMOTE_URL is cloned to
          the current directory.  The "username" in the remote
          repository is prepended to the destination directory
          basename.

EXAMPLE:  $SELF_BASENAME 'git@github.com:foo/bar.git'
          Clones the remote repository to 'foo_bar.git'.
          Clones any associated wiki to 'foo_bar_wiki.git'.

  NOTES:  Supported URLs are hardcoded into the script.
          Existing files will not be overwritten.
          Also clones the wiki.  (TODO: add option for this)

EOF
    exit 1
fi


readonly repo_url="$1"
wiki_url="${repo_url/.git/.wiki.git}"

case "$repo_url" in
    git@github.com:*)
        # GitHub SSH
        repo_dest="${repo_url//git@github.com:}"
        ;;
    https://github.com*)
        # GitHub HTTPS
        repo_dest="${repo_url//https:\/\/github.com\/}"
        ;;
    https://bitbucket.org*)
        # Bitbucket HTTPS
        repo_dest="${repo_url//https:\/\/bitbucket.org\/}"
        ;;
    git@gitlab.com:*)
        # GitLab SSH
        repo_dest="${repo_url//git@gitlab.com:}"
        ;;
    https://gitlab.com/*)
        # GitLab HTTPS
        repo_dest="${repo_url//https:\/\/gitlab.com\//}"
        ;;
    https://opendev.org/*)
        # OpenDev HTTPS
        repo_dest="${repo_url//https:\/\/opendev.org\//}"
        ;;
    *)
        printf 'Unsupported source repository URL .. Exiting.\n'
        exit 1
        ;;
esac


git_clone_no_clobber()
{
    local _url="$1"
    local _dest="$2"

    if [ -e "$_dest" ]
    then
        printf 'Skipped "%s" ..\n' "$_url"
        printf 'Destination exists: "%s"\n' "$_dest"
    else
        git clone "$_url" "$_dest"
    fi
}

repo_dest="${repo_dest/\//_}"
repo_dest="$(basename -- "$repo_dest")"
git_clone_no_clobber "$repo_url" "$repo_dest"

wiki_dest="${repo_dest/.git/_wiki.git}"
wiki_dest="$(basename -- "$wiki_dest")"
git_clone_no_clobber "$wiki_url" "$wiki_dest"

exit $?
