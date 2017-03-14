#!/usr/bin/env bash


if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Required program ffmpeg is not available. Exiting." 2>&1
    exit 1
fi

if ! command -v xdpyinfo >/dev/null 2>&1; then
    echo "Required program xdpyinfo is not available. Exiting." 2>&1
    exit 1
fi


ffmpeg -video_size "$(xdpyinfo | grep 'dimensions:'|awk '{print $2}')" \
       -framerate 25 -f x11grab -i :0.0 -f pulse -ac 2 -i default      \
       "screencapture_$(date "+%FT%H%M%S").mkv"

