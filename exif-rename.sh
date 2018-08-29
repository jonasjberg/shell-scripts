#!/usr/bin/env bash
#                                 ~~~~~~~~~~~
#                                 exif-rename
#                                 ~~~~~~~~~~~
#                    Copyright (C) 2015-2018 Jonas Sjöberg
#                        https://github.com/jonasjberg
#
#                 Rename images based on exif time/date data.
#      Searches the output of "exiftool" for contents of "EXIF_FIELD_NAMES"
#     Contents of EXIF_FIELD_NAMES are ordered by priority, from high to low.
#      The first match is used, so put whatever exif-fields that are more
#      likely to contain the correct date/time higher in the list below.
#    Compared to similar programs/scripts out there, this is a particularly
#       poor implementation with astonishingly lackluster functionality.
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

set -o noclobber -o nounset -o pipefail


# Example exiftool output this script will process:
#
# > $ exiftool 2015-01-31\ 00.25.39.jpg | grep -i date
#
#     File Modification Date/Time     : 2015:01:31 00:25:39+01:00
#     File Access Date/Time           : 2015:06:04 05:58:32+02:00
#     File Inode Change Date/Time     : 2015:05:20 12:29:25+02:00
#     Modify Date                     : 2015:01:31 00:25:39
#     Date/Time Original              : 2015:01:31 00:25:39
#     Create Date                     : 2015:01:31 00:25:39

# Search strings ordered by priority, from high to low;
EXIF_FIELD_NAMES[0]='CreateDate'
EXIF_FIELD_NAMES[1]='DateTimeCreated'
EXIF_FIELD_NAMES[2]='DateTimeOriginal'
EXIF_FIELD_NAMES[3]='DateTimeDigitized'
EXIF_FIELD_NAMES[4]='MediaCreateDate'
EXIF_FIELD_NAMES[5]='TrackCreateDate'
EXIF_FIELD_NAMES[6]='MetadataDate'
#EXIF_FIELD_NAMES[7]='ModifyDate'
#EXIF_FIELD_NAMES[8]='ModificationDate'
#EXIF_FIELD_NAMES[9]='ProfileDateTime'
#EXIF_FIELD_NAMES[10]='FileAccessDateTime'

EXIFTOOL_OPTS=(-short --composite -duplicates "-*date*" "-*year*")
VERBOSE_MODE=true
DEBUG_MODE=false
OPTION_WRITE=false

# TODO: Add option to enable prepending timestamp to existing basename prefix.
OPT_PREFIX_TIMESTAMP=true


PROGNAME="$(basename $0)"
C_RED="$(tput setaf 1)"
C_GREEN="$(tput setaf 2)"
C_YELLOW=$(tput setaf 3)
C_RESET="$(tput sgr0)"

count_skipped=0
count_failed=0
count_total=0
count_success=0


print_usage_info()
{
    cat <<EOF

"${PROGNAME}"  --  rename files using exiftool

  USAGE:  $PROGNAME [-d] [-h] [-v] [-w] [FILE...]"

  OPTIONS:  -d   Enable printing debug information.
            -h   Display usage information and exit.
            -q   Decrease output verbosity.
            -w   Perform the rename operation.

  All options are optional. Default behaviour is a "dry run" mode,
  where files are not actually renamed.  Use "-w" to rename files.

EOF
}

msg()
{
    $VERBOSE_MODE && printf "$@"
}

log_warn()
{
    msg "${C_YELLOW}[WARNING]${C_RESET} %s\n" "$1"
    shift

    while test "$#" -gt "0"
    do
        msg "          %s\n" "$1"
        shift
    done
}

log_fail()
{
    msg "${C_RED}[FAILURE]${C_RESET} %s\n" "$*"
    count_failed="$((count_failed + 1))"
}

log_skip()
{
    log_warn "$*"
    count_skipped="$((count_skipped + 1))"
}

log_ok()
{
    msg "${C_GREEN}[SUCCESS]${C_RESET} %s\n" "$*"
    count_success="$((count_success + 1))"
}

log_debug()
{
    $DEBUG_MODE && printf '[DEBUG] %s\n' "$*"
}

clean_up_timestamp()
{
    local tstp="$1"
    tstp="${tstp//:/-}"             # Replace : with -
    tstp="${tstp//+/-}"             # Replace + with -
    tstp="${tstp//\ /_}"            # Replace spaces with _
    sed 's/^[_-]\+//g' <<< "$tstp"  # Remove leading _ or -
}

check_timestamp()
{
    grep -oE '[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]_[0-2][0-9]-[0-5][0-9]-[0-5][0-9]' #<<< "$1"
}

format_timestamp()
{
    # Input matching 'YYYY-MM-DD_HH-MM-SS' is returned as 'YYYY-MM-DDTHHMMSS'.
    sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)_\([0-9]\{2\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\1-\2-\3T\4\5\6/' #<<< "$1"
}

handle_arg()
{
    local arg_abspath="$1"
    local arg_extension="${arg_abspath##*.}"
    local arg_dirname="$(dirname -- "$arg_abspath")"

    log_debug "Got argument: \"${arg_abspath}\""
    if exiftool_output="$(exiftool "${EXIFTOOL_OPTS[@]}" "$arg_abspath" 2>&1)" >/dev/null
    then
        log_debug "$exiftool_output"
    else
        log_debug "${exiftool_output:-"exiftool returned non-zero"}"
        return 1
    fi

    # Grep EXIF data, break at first match.
    matched_field='None'
    for field in "${EXIF_FIELD_NAMES[@]}"
    do
        timestamp="$(grep -ai --max-count=1 -- "$field" <<< "$exiftool_output" | cut -d':' -f2-)"

        # Filter out unwanted cruft.
        timestamp="$(grep -iv -- "binary" <<< "$timestamp")"
        timestamp="$(grep -v -- "0000:00:00" <<< "$timestamp")"
        timestamp="$(grep -v -- "2002:12:08 12:00:00" <<< "$timestamp")"

        # Additional optional filtering.
        # timestamp="$(grep -v -- "2015" <<< "$timestamp")"
        # timestamp="$(grep -v -- "2016" <<< "$timestamp")"

        [ -n "$timestamp" ] && { matched_field="$field" ; break ; }
    done

    log_debug "\"raw\" timestamp: \"$timestamp\""
    timestamp="$(clean_up_timestamp "$timestamp" | check_timestamp | format_timestamp)"
    if [ -z "$timestamp" ]
    then
        log_skip "Unable to retrieve timestamp"
        return 1
    fi
    log_debug "processed timestmap: \"$timestamp\""

    local arg_basename="$(basename -- "$arg_abspath")"
    local arg_basename_prefix="${arg_basename%.*}"

    # Define format of destination basename.
    local _dest_basename
    if $OPT_PREFIX_TIMESTAMP
    then
        _dest_basename="${timestamp} ${arg_basename_prefix}.${arg_extension}"
    else
        _dest_basename="${timestamp}.${arg_extension}"
    fi

    local dest_abspath="${arg_dirname}/${_dest_basename}"
    if [ -e "$dest_abspath" ]
    then
        log_skip "Destination exists: \"${dest_abspath}\""
        return 1
    fi

    local rename_cmd="mv -nv -- \"$arg_abspath\" \"$dest_abspath\""
    if $OPTION_WRITE
    then
        eval "${rename_cmd}"
        return $?
    else
        log_debug "Would have executed: \"${rename_cmd}\""
        _rename_msg="$(printf '"%s" -> "%s"\n' "$arg_abspath" "$dest_abspath")"
        log_ok "Would have renamed ${_rename_msg} (${matched_field})"
        return 0
    fi
}


if ! command -v "exiftool" &>/dev/null
then
    log_fail "This program requires \"exiftool\". Make sure it is installed."
    exit 1
fi

if [ "$#" -eq "0" ]
then
    log_warn "Positional arguments missing! At least one is required."
    print_usage_info
    exit 0
else
    while getopts dhqw opt
    do
        case "$opt" in
            d) DEBUG_MODE=true ;;
            h) print_usage_info ; exit 0 ;;
            q) VERBOSE_MODE=false ;;
            w) OPTION_WRITE=true ;;
        esac
    done

    shift $(( $OPTIND - 1 ))
fi

for arg in "$@"
do
    arg="$(realpath -e -- "$arg")"
    [ -f "$arg" ] || { log_skip "Not a file: \"${arg}\"" ; continue ; }
    [ -r "$arg" ] || { log_skip "Unreadable: \"${arg}\"" ; continue ; }

    handle_arg "$arg"
    if [ "$?" -ne "0" ]
    then
        log_skip "Skipped \"${arg}\" .."
    else
        count_success="$((count_success + 1))"
    fi

    count_total="$((count_total + 1))"
done

if $VERBOSE_MODE
then
    printf '\n\nSUMMARY STATS\n' "$count_total"
    printf 'Total   : %d\n' "$count_total"
    printf 'Renamed : %d\n' "$count_success"
    printf 'Skipped : %d\n' "$count_skipped"
    printf 'FAILED  : %d\n' "$count_failed"
fi

if [ "$count_failed" -gt "0" ]
then
    exit 1
else
    exit 0
fi

