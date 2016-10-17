#!/usr/bin/env bash

# Very specific hack for one of my laptops that won't handle fan speed
# correctly from a cold boot.  This script tries to update packages, waits a
# bit and the reboots after a countdown of sorts.
# Uses my own 'notify-send' wrapper 'notify' if available.
#     ____________________________________________________________________
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
#     ____________________________________________________________________
#

if sudo apt-get update && sudo apt-get upgrade --assume-yes
then
    if command -v "notify" >/dev/null 2>&1
    then
        export NOTIFYMSG_TITLE="System reboot imminent"
        notify "Rebooting in 15 seconds .." ; sleep 10
        notify "Rebooting in 5 seconds .."  ; sleep 1
        notify "Rebooting in 4 seconds .."  ; sleep 1
        notify "Rebooting in 3 seconds .."  ; sleep 1
        notify "Rebooting in 2 seconds .."  ; sleep 1
        notify "Rebooting in 1 seconds .."  ; sleep 1
        notify "Rebooting NOW!" ;
    else
        echo "Rebooting in 15 seconds .." 1>&2 ; sleep 10
        echo "Rebooting in 5 seconds .."  1>&2 ; sleep 1
        echo "Rebooting in 4 seconds .."  1>&2 ; sleep 1
        echo "Rebooting in 3 seconds .."  1>&2 ; sleep 1
        echo "Rebooting in 2 seconds .."  1>&2 ; sleep 1
        echo "Rebooting in 1 seconds .."  1>&2 ; sleep 1
        echo "Rebooting NOW!"             1>&2 
    fi

    sudo reboot
fi
