#!/usr/bin/env sh


if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Dependency 'ffmpeg' not met." >&2
    exit 1
elif ! command -v xdpyinfo >/dev/null 2>&1; then
    echo "Dependency 'xdpyinfo' not met." >&2
    exit 1
fi

printf -v FileName "screencapture_%(%FT%X)T.mkv" -1
ScrRes(){ awk '{if(/dimensions:/){printf("%s ", $2)}}' <<< "$(xdpyinfo)"; }
ffmpeg -loglevel 16 -video_size "$ScrRes" -framerate 25 -f x11grab\
	-i "${DISPLAY:-:0.0}" -f pulse -ac 2 -i default "$FileName"

