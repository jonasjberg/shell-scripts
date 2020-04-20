#!/usr/bin/env bash

# today-dir.sh
# ============
# Written by Jonas Sjöberg in 2016
#
# Create a daily working directory called "today", which is a symlink to a
# directory with the actual date.
#
# Example: "~/jonas/today" symlinks to "~/jonas/Archive/2016-05-29" and ..
#          "~/jonas/today" symlinks to "~/jonas/Archive/2016-05-30" the next day
#
#
# Similar and more sophisticated project:
# https://github.com/mdsummers/today_cmd

VERBOSE=1

msg()
{
    [ "$VERBOSE" -lt "1" ] && return
    local timestamp="$(date +%FT%M:%M:%S)"
    printf '%s [%s] %s\n' "$timestamp" "$(basename $0)" "$*"
}

# Base directory where everything is stored.
archive_dir="${HOME}/Archive"
[ ! -d "$archive_dir" ] && mkdir -vp "$archive_dir"

# Create todays directory if it does not exist already.
todays_date="$(command date '+%F')"
today_dir="${archive_dir}/${todays_date}"
if [ ! -d "$today_dir" ]
then
    mkdir -vp "$today_dir"
else
    msg "Directory \"$today_dir\" already exists."
fi


# Path to the symlink pointing to todays directory
link_path="${HOME}/today"

# Check the state of any existing symlink, remove if stale.
if [ -L "$link_path" ]
then
    if [ "$(readlink -- "$link_path")" == "$today_dir" ]
    then
        msg "The symlink exists and points to todays directory."
    else
        msg "The symlink exists but does not point to todays directory .."
        rm -v -- "$link_path"
    fi
fi

# Create a new symlink if path does not already exist or is a (dead) symlink.
if [ ! -e "$link_path" -a ! -h "$link_path" ]
then
    ln -vs -- "$today_dir" "$link_path"
else
    msg "Symlink path \"${link_path}\" already exists! Aborting.."
fi


exit $?
