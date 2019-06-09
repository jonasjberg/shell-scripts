#!/usr/bin/env bash

# convert-video-to-mp4.sh       Copyright 2016-2019 Jonas Sjöberg
# ~~~~~~~~~~~~~~~~~~~~~~~       https://github.com/jonasjberg
#                               http://www.jonasjberg.com
#
# Re-encodes videos using generic settings that should work good enough
# for most source media, with the primary purpose of reduced disk space
# prior to read-only archive storage.

set -o errexit -o noclobber -o nounset


declare -a ffmpeg_options_global=(
    -n  # Do not overwrite output files, and exit immediately if a specified
        # output file already exists.
    -loglevel warning
)
declare -a ffmpeg_options_input=(
)
declare -a ffmpeg_options_output=(
    -c:v libx264
    -preset veryslow
    -crf 18
    -c:a libmp3lame
    -qscale:a 2
    -ac 2
    -ar 44100
    -map_metadata 0:g
)


if ! command -v ffmpeg &>/dev/null
then
    printf 'This script requires "ffmpeg" ..\n'
    exit 1
fi


if [ $# -eq 0 ]
then
    cat <<EOF

    USAGE:  $(command basename -- "$0") [FILE]...

    Where FILE is one or more path(s) to video file(s) to be re-encoded.
    The destination path is the original path without any file extension
    and with an extra "_reencoded.mp4" appended.  FILE is skipped if the
    destination path already exists.

EOF
    exit 0
fi


for arg in "$@"
do
    [ -e "$arg" ] || continue

    if ! file_abspath="$(command realpath --canonicalize-existing -- "$arg")"
    then
        continue
    fi

    dest_abspath="${file_abspath%.*}_reencoded.mp4"
    printf 'Writing to path "%s" ..\n' "$dest_abspath"

    command ffmpeg "${ffmpeg_options_global[@]}" -i "$file_abspath" \
                   "${ffmpeg_options_output[@]}" -- "$dest_abspath"
done

exit 0
