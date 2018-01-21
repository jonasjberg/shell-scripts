#!/usr/bin/env bash

# convert-video-to-mp4          Copyright (C) 2016-2017 Jonas Sjöberg
# ~~~~~~~~~~~~~~~~~~~~          https://github.com/jonasjberg
#                               http://www.jonasjberg.com
#
# Convert videos to mp4 using ffmpeg, motivated by reducing disk space.
# Especially screen capture recordings in ogv- and webm-formats seem
# to take up more space than necessary in my usage. This solves that.


set -e

function handle_arg()
{
    src="$1"
    dest="${1%.*}.mp4"
    printf '%-25s : "%s"\n' "converting from source" "$src"
    printf '%-25s : "%s"\n' "to destination"         "$dest"

    # Information on ffmpeg command options used:
    # http://askubuntu.com/questions/12182/how-can-i-convert-an-ogv-file-to-mp4
    # http://askubuntu.com/a/470475
    ffmpeg -i "$src" -c:v libx264 -preset veryslow -crf 22 -c:a libmp3lame \
           -qscale:a 2 -ac 2 -ar 44100 -map_metadata 0:g -- "$dest"
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
    printf "%-8s %s\n" "" "Specified file(s) will be converted to mp4."
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