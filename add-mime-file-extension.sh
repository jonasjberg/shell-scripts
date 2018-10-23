#!/usr/bin/env bash

#   Copyright(c) 2016-2017 Jonas Sjöberg
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

SELF="$(basename "$0")"


print_usage_info()
{
    cat <<EOF

"${SELF}"
Adds extensions to file names matching the files detected MIME type.

  USAGE:  ${SELF} ([OPTIONS]) [PATH...]

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
    local arg="$1"
    [ -f "$arg" ] || return

    # printf 'Got path: "%s"\n' "$arg"

    case $(file --mime-type --brief -- "$arg") in

        # Audio
        audio/x-flac) ext=flac;;
        audio/mpeg) ext=mp3;;
        application/ogg) ext=ogg;;

        # Video
        video/mp4) ext=mp4;;
        video/x-flv) ext=flv;;
        #application/octet-stream) ext=webm;;
        application/x-shockwave-flash) ext=swf;;

        # Images
        image/png) ext=png;;
        image/jpeg) ext=jpg;;
        image/gif) ext=gif;;
        image/tiff) ext=tif;;
        image/x-ico) ext=ico;;

        # Text
        text/plain) ext=txt;;
        text/html) ext=html;;
        text/rtf) ext=rtf;;
        text/x-python) ext=py;;
        #text/x-c++) ext=cpp;;
        #text/x-c) ext=scss;;
        #text/x-shellscript) ext=sh;;
        application/pdf) ext=pdf;;
        application/xml) ext=xml;;

        # Documents
        application/vnd.ms-powerpoint) ext=ppt;;
        application/msword) ext=doc;;

        # Fonts
        application/x-font-ttf) ext=ttf;;
        application/vnd.ms-opentype) ext=otf;;

        # Archive
        application/x-gzip) ext=tar.gz;;
        application/x-bzip2) ext=tar.bz;;

        *) continue;;
        # *) { echo "Unhandled case: \"${arg}\"" ; continue ; } ;;
    esac

    # File name extension is already correct.
    [[ ${arg} = *.${ext} ]] && continue

    _mv_verbose_flag=''
    [ "$option_verbose" = 'true' ] && _mv_verbose_flag='v'

    if [ "$option_dry_run" = 'true' ]
    then
        printf 'Would have executed: %s\n' "mv -n${_mv_verbose_flag} -- "$arg" "${arg}.${ext}""
    else
        mv -n${_mv_verbose_flag} -- "$arg" "${arg}.${ext}"
    fi
}


option_dry_run='false'
option_verbose='false'

if [ "$#" -eq "0" ]
then
    print_usage_info
    exit 0
else
    while getopts dhv opt
    do
        case "$opt" in
            d) option_dry_run='true' ;;
            h) print_usage_info ; exit 0 ;;
            v) option_verbose='true' ;;
        esac
    done

    shift $(( $OPTIND - 1 ))
fi

for path_argument in "$@"
do
    add_extension_from_mime "$(realpath -e -- "$path_argument")"
done
