#!/usr/bin/env bash
#                                 .----------.
#                                clampimgheight
#                                 '----------'
#
#      Columnate images taller than IMAGE_HEIGHT_MAX using ImageMagick.
#   Useful for processing very tall images produced by the 'www2png' script.
# Doesn't hard limit the height but tries its best to equally divide the image
# into the number of columns needed while keeping the split images height equal.
#   Thus, the output image height may deviate slightly from the set maximum.
#
#                     Copyright(c)2015-2017 Jonas Sjöberg
#                        https://github.com/jonasjberg
#_______________________________________________________________________________
#
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
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#_______________________________________________________________________________


IMAGE_HEIGHT_MAX=2000

set -e                                                  # exit on first error
#set -x                                                # debug mode

DEBUG_MODE=true
PROGNAME="$(basename $0)"                               # name of this script
DEFAULT_ERROR_MSG="Unknown (unspecified) error!"
DEFAULT_ERROR_CODE=2


die()
{
    local msg="${2:-${DEFAULT_ERROR_MSG}}"
    printf "${PROGNAME} [ERROR] %s\n" "${msg}" 1>&2
    exit "${1:-${DEFAULT_ERROR_CODE}}"
}

msg_warn()
{
    printf "${PROGNAME} [WARNING] %s\n" "$*" 1>&2
}

msg_debug()
{
    [ "$DEBUG_MODE" == "true" ] && printf "${PROGNAME} [DEBUG] %s\n" "$*"
}

assert_dependencies_available()
{
    if ! command -v "convert" >/dev/null 2>&1
    then
        die 127 "This script requires \"convert\" to run."
    elif ! command -v "identify" >/dev/null 2>&1
    then
        die 127 "This script requires \"identify\" to run."
    fi
}


if [ "$#" -ne "2" ]
then
    die 1 "USAGE: ${PROGNAME} [INPUT_IMAGE] [OUTPUT_IMAGE]"
else
    assert_dependencies_available

    TEMPDIR="$(mktemp -d /tmp/${PROGNAME}.XXXXXX)"
    if [ ! -d "$TEMPDIR" ]
    then
        die 1 "Unable to create temporary directory"
    fi

    in_file="$(realpath -e -- "$1")"
    if [ -z "$in_file" ] || [ ! -f "$in_file" ]
    then
        die 1 "Not a file: \"${in_file}\""
    else
        case "$(file --mime-type --brief -- "$in_file")" in
            image/*) ;;
            *) die 1 "Not an image: \"${in_file}\"" ;;
        esac
    fi

    out_file="${2:-}"
    if [ -e "$out_file" ]
    then
        die 1 "Destination exists: \"${out_file}\""
    fi

    # Initialize counter and get initial image height.
    number_of_splits=1
    initial_image_height="$(identify -format "%h" "$in_file")"

    # Check if initial image height is less than or equal to IMAGE_HEIGHT_MAX.
    if [ "$initial_image_height" -le "$IMAGE_HEIGHT_MAX" ]
    then
        echo "Image height is already less than or equal to IMAGE_HEIGHT_MAX"
        echo "(Height: ${initial_image_height}  <  Max: ${IMAGE_HEIGHT_MAX})"
    fi

    # Get the number of vertical splits needed.
    target_image_height="$initial_image_height"
    while [ "$target_image_height" -gt "$IMAGE_HEIGHT_MAX" ]
    do
        target_image_height="$((${initial_image_height} / ${number_of_splits}))"
        number_of_splits="$[$number_of_splits +1]"
    done

    if [ -z "$number_of_splits" ]
    then
        die 1 "Failed to calculate number of splits"
    fi

    msg_debug "           input filename: ${in_file}"
    msg_debug "             image height: ${initial_image_height}"
    msg_debug "         IMAGE_HEIGHT_MAX: ${IMAGE_HEIGHT_MAX}"
    msg_debug "number of splits required: ${number_of_splits}"

    # Get a name for intermediate files.
    in_file_ext="${in_file##*.}"
    in_file_basename_no_ext="$(basename -- "$input")"
    horiz_split="${TEMPDIR}/${in_file_basename_no_ext}_%02d.${in_file_ext}"

    # Chop up image horizontally into 'number_of_splits' pieces.
    #   http://www.imagemagick.org/Usage/crop/#crop_equal
    convert "$in_file" -crop 1x${number_of_splits}@ +repage +adjoin $horiz_split

    # Merge all pieces horizontally.
    #   http://www.imagemagick.org/Usage/layers/
    #   http://www.imagemagick.org/Usage/option_link.cgi?append
    convert +append "${TEMPDIR}/*.${in_file_ext}" "$out_file"
fi


exit $?

