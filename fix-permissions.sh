#!/usr/bin/env bash

# Recursively set permissions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Recursively changes file and directory permissions, owner and group.
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
#_______________________________________________________________________________


#set -e                         # exit on first error
#set -x                         # debug mode
set -o pipefail


THIS_SCRIPT_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
EXTERNAL_CONFIG_FILE="${THIS_SCRIPT_PATH}/fix-permissions_config"
if [ -f "$EXTERNAL_CONFIG_FILE" ]
then
    printf "Using external configuration: \"${EXTERNAL_CONFIG_FILE}\" ..\n"
    . "$EXTERNAL_CONFIG_FILE"
else
    printf "Not a file: \"${EXTERNAL_CONFIG_FILE}\" ..\n"
    printf "Using default configuration (!)\n"
fi

#                       OWNER   GROUP   OTHER
# DIRECTORIES: 775  ->  R W X   R W X   R   X
#       FILES: 664  ->  R W     R W     R

[ -z "$CHMOD_DIRS" ]  && CHMOD_DIRS="775"
[ -z "$CHMOD_FILE" ]  && CHMOD_FILE="664"
[ -z "$CHOWN_USER" ]  && CHOWN_USER="jonas"
[ -z "$CHOWN_GROUP" ] && CHOWN_GROUP="jonas"


function msg_error()
{
    printf "[ERROR] %s\n" "$*" >&2
}

function msg_argerr()
{
    msg_error "${1}: \"${2}\""
}

function msg_usage()
{
    printf "\nUSAGE: $(basename "$0") [PATH]\n"
    printf "\nModifies owner, group and permissions for PATH recursively using options:\n"
    local FMT="  %-30.30s: %s\n"
    printf "$FMT" "chown (owner, group)"       "[${CHOWN_USER}] [${CHOWN_GROUP}]"
    printf "$FMT" "chmod (directories, files)" "[${CHMOD_DIRS}] [${CHMOD_FILE}]"
    printf "\nNote that this script should be executed with elevated privileges.\n"
}

if [ "$#" -eq "0" ]
then
    msg_usage
    exit 1
fi

path="${1%/}"
[ -z "$path" ] && { msg_argerr "Got null argument" "$path" ; exit 1 ; }
[ -d "$path" ] || { msg_argerr "Not a directory"   "$path" ; exit 1 ; }

printf "Using path: \"${path}\"\n"
read -rsp $'Press any key to continue .. (ctrl-c aborts)\n' -n 1 key

printf "\nChowning directories and files .."
if chown -R "${CHOWN_USER}:${CHOWN_GROUP}" "${path}" 2>/dev/null
then
    printf " [OK]\n"
else
    printf " [FAILED]\n"
fi

printf "Chmodding directories .. "
find "$path" -xdev -type d -exec chmod $CHMOD_DIRS '{}' \;
[ "$?" -eq "0" ] && printf "[DONE]\n"

printf "Chmodding files .. "
find "$path" -xdev -type f -exec chmod $CHMOD_FILE '{}' \;
[ "$?" -eq "0" ] && printf "[DONE]\n"

[ -n "$SECONDS" ] && printf "\nTotal execution time: ${SECONDS} seconds\n"

exit $?
