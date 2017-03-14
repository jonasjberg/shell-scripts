#!/usr/bin/env bash

ffmpeg -video_size $(xdpyinfo | grep 'dimensions:'|awk '{print $2}') -framerate 25 -f x11grab -i :0.0 -f pulse -ac 2 -i default "screencapture_$(date "+%FT%H%M%S").mkv"
