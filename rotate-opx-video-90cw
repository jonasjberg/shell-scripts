#!/usr/bin/env bash

# rotate-opx-video-90cw         Copyright (C) 2016 Jonas Sjöberg
# ~~~~~~~~~~~~~~~~~~~~~         https://github.com/jonasjberg
#
# Rotate videos 90 degrees clockwise using ffmpeg, while handling rotation
# information stored in video metadata properly. At least I hope it does.
# Seems to work for what I use it for, which is rotating videos recorded with
# the stock camera app (v1.1.0) on my OnePlus X.

set -e

function handle_arg()
{
    src="$1"
    APPEND_STR=" - 90cw"
    NEW_EXT="mp4"
    dest="${1%.*}${APPEND_STR}.${NEW_EXT}"

    # 90 degrees CW                 : -vf "transpose=1"
    # 90 degrees CCW                : -vf "transpose=2"
    # 90 degrees CW + vertical flip : -vf "transpose=2"
    # 180 degrees                   : -vf "transpose=2,transpose=2"
    ffmpeg -noautorotate -i "$src" \
           -vf "transpose=1" -metadata:s:v:0 rotate=0 -c:a copy "$dest"
}

function msg_error()
{
    printf '[ERROR] %s : "%s" ..\n' "$1" "$2" >&2
}


if ! command -v ffmpeg >/dev/null 2>&1; then
    msg_error "Unable to continue without program" "ffmpeg"
    exit 1
fi

if [ $# -eq 0 ]
then
    printf "%-8s %s\n" "Usage:" "$(basename $0) [FILE]..."
    printf "%-8s %s\n" "" "Specified file(s) will be rotated 90 degrees clockwise."
    exit 1
else
    for arg in "$@"
    do
        [ -z "$arg" ] && { msg_error "Got null argument" "$arg" ; continue ; }
        [ -e "$arg" ] || { msg_error "Does not exist"    "$arg" ; continue ; }
        [ -d "$arg" ] && { msg_error "Is a directory"    "$arg" ; continue ; }
        [ -f "$arg" ] || { msg_error "Not a file"        "$arg" ; continue ; }
        handle_arg "${arg}"
    done

    exit $?
fi
