#!/usr/bin/env bash

# reencode-opx-video            Copyright (C) 2016-2017 Jonas Sjöberg
# ~~~~~~~~~~~~~~~~~~            https://github.com/jonasjberg
#
# Reencode videos using ffmpeg to save space, while handling rotation
# information stored in video metadata properly. At least I hope it does.
# The videos recorded with the stock camera app (v1.1.0) on my OnePlus X
# contains a lot of duplicate frames and take up way too much space for 
# the quality.

set -e

function handle_arg()
{
    src="$1"
    APPEND_STR=" - reencoded"
    NEW_EXT="mp4"
    dest="${1%.*}${APPEND_STR}.${NEW_EXT}"

    # 90 degrees CW                 : -vf "transpose=1"
    # 90 degrees CCW                : -vf "transpose=2"
    # 90 degrees CW + vertical flip : -vf "transpose=2"
    # 180 degrees                   : -vf "transpose=2,transpose=2"
    ffmpeg -noautorotate -i "$src" \
           -metadata:s:v:0 rotate=0 -c:a copy "$dest"
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
    printf "%-8s %s\n" "" "Specified file(s) will be reencoded."
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
