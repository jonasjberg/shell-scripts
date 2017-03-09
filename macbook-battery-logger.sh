#!/usr/bin/env bash

# macbook-battery-logger.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright (c) 2017 Jonas Sjöberg
# <http://www.jonasjberg.com>
#
# Generates a CSV log of MacBook laptop battery statistics.
# The statistics is printed to stdout and appended to "LOG_FILE".
# 
# Example output:
# [2017-03-09T20:02:43] Charge Remaining (mAh): 5864,  Voltage (mV): 12494,  Amperage (mA): 0
# [2017-03-09T20:08:45] Charge Remaining (mAh): 5864,  Voltage (mV): 12494,  Amperage (mA): 0
# [2017-03-09T20:09:45] Charge Remaining (mAh): 5864,  Voltage (mV): 12493,  Amperage (mA): 0


LOG_FILE="macbook-battery.log"


case "$OSTYPE" in
    darwin*)  ;;
    *) echo "Unsupported os type: \"${OSTYPE}\" .." 1>&2
       exit 1 ;;
esac


while true
do
    timestamp="$(date "+%Y-%m-%dT%H:%M:%S")"
    chargeremain="$(system_profiler SPPowerDataType | grep 'Charge Remaining' | sed 's/^[ \t]*//')"
    voltage="$(system_profiler SPPowerDataType | grep 'Voltage' | sed 's/^[ \t]*//')"
    amperage="$(system_profiler SPPowerDataType | grep 'Amperage' | sed 's/^[ \t]*//')"

    echo "[${timestamp}] ${chargeremain},  ${voltage},  ${amperage}" | tee -a "$LOG_FILE"
    sleep 60
done
