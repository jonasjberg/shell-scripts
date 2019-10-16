#!/usr/bin/env bash

#   Copyright(c) 2016-2019 Jonas Sjöberg
#   http://www.jonasjberg.com
#   https://github.com/jonasjberg
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#                   (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#               GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set -o noclobber -o nounset -o pipefail

readonly SELF_BASENAME="$(basename -- "$0")"


print_usage_info()
{
    cat <<EOF

"${SELF_BASENAME}"
Adds extensions to file names matching the files detected MIME type.

  USAGE:  ${SELF_BASENAME} ([OPTIONS]) [PATH...]

  OPTIONS:  -h   Display usage information and exit.
            -d   "Dry run" or simulation mode. Test what would happen.
            -v   Increased verbosity.

  All options are optional. Default behaviour is to perform the renaming
  operations and only print error messages.
  Any number of paths to be renamed should be given after the options.

EOF
}

add_extension_from_mime()
{
    local _filepath="$1"
    local _ext
    local _filepath_mimetype

    if ! _filepath_mimetype="$(file --mime-type --brief -- "$_filepath")"
    then
        return 1
    fi

    case "$_filepath_mimetype" in
        inode/directory) return 0 ;;

        application/CDFV2) _ext='db' ;;
        audio/x-flac) _ext='flac' ;;
        audio/mpeg) _ext='mp3' ;;
        application/ogg) _ext='ogg' ;;

        video/mp4) _ext='mp4' ;;
        video/x-flv) _ext='flv' ;;

        application/octet-stream)
            # Use any existing extension in some special cases where file
            # (file-5.25) seems to not properly detect the file type.
            case "$_filepath" in
                *.3gp) _ext='3gp' ;;
                *.webm) _ext='webm' ;;
            esac ;;

        application/x-shockwave-flash) _ext='swf' ;;

        image/png) _ext='png' ;;
        image/jpeg) _ext='jpg' ;;
        image/gif) _ext='gif' ;;
        image/tiff) _ext='tif' ;;
        image/webp) _ext='webp' ;;
        image/x-ico) _ext='ico' ;;
        image/x-ms-bmp) _ext='bmp' ;;

        text/plain)
            case "$_filepath" in
                *.md) _ext='md' ;;
                *.txt) _ext='txt' ;;
                *) _ext='txt' ;;
            esac ;;

        text/html) _ext='html' ;;
        text/rtf) _ext='rtf' ;;
        text/x-python) _ext='py' ;;
        #text/x-c++) _ext='cpp' ;;
        #text/x-c) _ext='scss' ;;
        text/x-shellscript) _ext='sh' ;;
        application/pdf) _ext='pdf' ;;
        application/xml) _ext='xml' ;;

        application/vnd.ms-powerpoint) _ext='ppt' ;;
        application/msword) _ext='doc' ;;

        application/x-font-ttf) _ext='ttf' ;;
        application/vnd.ms-opentype) _ext='otf' ;;

        application/x-gzip) _ext='tar.gz' ;;
        application/x-bzip2) _ext='tar.bz' ;;

        *) printf 'Unhandled MIME-type "%s" from file "%s"\n' "$_filepath_mimetype" "$_filepath"
           return 1 ;;
    esac

    # File name extension is absent or unknown.
    [[ -z ${_ext:-} ]] && return 0

    # File name extension is already correct.
    [[ ${_filepath} = *.${_ext} ]] && return 0

    local _dest_filepath="${_filepath}.${_ext}"

    # TODO: Remove current incorrect extension before adding the new extension.
    _dest_filepath="${_dest_filepath/.jpeg.jpg/.jpg}"
    _dest_filepath="${_dest_filepath/.jpeg.png/.png}"
    _dest_filepath="${_dest_filepath/.jpg.png/.png}"
    _dest_filepath="${_dest_filepath/.png.jpg/.jpg}"

    if [ "$option_dry_run" = 'true' ]
    then
        printf 'Would have renamed "%s" to "%s"\n' "$_filepath" "$_dest_filepath"
        return 0
    fi

    if [ "$option_verbose" = 'true' ]
    then
        mv -nv -- "$_filepath" "$_dest_filepath"
    else
        mv -n -- "$_filepath" "$_dest_filepath"
    fi
}


command -v realpath &>/dev/null || exit 1


if [ "$#" -eq "0" ]
then
    print_usage_info
    exit 0
fi


option_dry_run='false'
option_verbose='false'

while getopts dvh opt
do
    case "$opt" in
        d) option_dry_run='true' ;;
        v) option_verbose='true' ;;
        h) print_usage_info ; exit 0 ;;
    esac
done

shift $(( OPTIND - 1 ))


for arg in "$@"
do
    [ -e "$arg" ] || continue

    if file_abspath="$(realpath --canonicalize-existing -- "$arg")"
    then
        add_extension_from_mime "$file_abspath"
    fi
done
