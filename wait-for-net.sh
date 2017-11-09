#!/usr/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# _____________________________________________________________________

# Spins in a loop until an arbitrary server is successfully pinged.
# Example usage:  ./wait-for-net.sh && dropbox

ARBITRARY_SERVER='ping.sunet.se'
POLL_WAIT_SECS=3

while true
do
    ping -q -c 1 "$ARBITRARY_SERVER" &>/dev/null \
    && break || sleep "$POLL_WAIT_SECS"
done

