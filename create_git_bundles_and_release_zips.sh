#!/bin/bash
set -o errexit -o nounset

# Exports local Git projects as ZIP files __without history__.
# Avoid! Best suited for creating releases than anything else.
#
# Also exports Git "bundle" files, containing the full history.
# See manpage git-bundle (1) - Move objects and refs by archive
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# First written 2023-xx-xx by jonas NO RIGHTS RESERVED! _WTFPL_


declare -a _REPOS_TO_EXPORT=(
    ~/dev/projects/ansible-devtools/
    ~/dev/projects/astermeoiwds
)
readonly _REVISION=master
declare -p _REPOS_TO_EXPORT _REVISION

readonly _DEST_DIRPATH="${DEST_DIRPATH:-${HOME}/git_bundles}"
declare -p _DEST_DIRPATH
mkdir -vp -- "$_DEST_DIRPATH"


for repopath in "${_REPOS_TO_EXPORT[@]}"
do
    [ -d "$repopath" ] || continue

    declare -p repopath
    pushd "$repopath" >/dev/null

    reponame="$(command basename -- "$repopath")"
    revision="$(command git rev-parse --short=16 "$_REVISION")"
    dest_filepath_zip="${_DEST_DIRPATH}/${reponame}_${_REVISION}_${revision}.zip"
    dest_filepath_bundle="${_DEST_DIRPATH}/${reponame}_${revision}.gitbundle"

    command git archive --format=zip --prefix="${reponame}/" "$_REVISION" > "$dest_filepath_zip"
    command git bundle create "$dest_filepath_bundle" --all

    popd >/dev/null
done



printf '.. OK!\n'
printf 'Projects exported to directory: %s\n' "$_DEST_DIRPATH"
exit 0
