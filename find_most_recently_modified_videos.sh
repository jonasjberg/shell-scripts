#!/bin/bash
# _________________________
# Jonas Sjöberg  2019-02-19
#    <jonas@jonasjberg.com>
# =========================

set -o nounset -o errexit -o pipefail -o noclobber


if [ $# -eq 0 ]
then
    cat <<EOF 2>&2

    Usage:  $(basename -- "${BASH_SOURCE[1]}") [DIRPATH]...

    Searches one or more directory paths recursively for video
    files as determined by the MIME-type AND the extension for
    "*.3gp"-files, which are not always detected as videos.

EOF
    exit 1
fi

# Hacky check if using the GNU or BSD version of 'stat'.
if man 1 stat | col -b | grep -q 'BSD General Commands Manual'
then
    stat_unixtime_filename() { stat -f '%m "%N"' "$1" ; }
else
    stat_unixtime_filename() { stat --format='%Y "%n"' -- "$1" ; }
fi


for arg in "$@"
do
    [ -r "$arg" ] || continue
    [ -d "$arg" ] || continue
    _dirpath_to_search="$arg"

    while IFS= read -r -d '' f
    do
        [ -f "$f" ] || continue

        case $(file --mime-type --brief -- "$f") in
            video/*) ;;  # OK!

            application/octet-stream)
                # Some '*.3gp'-files are not properly detected as being videos.
                case "$f" in
                    *.3gp) ;;  # OK!
                    *) continue ;;
                esac ;;

            *) continue ;;
        esac

        # Actual loop output ..
        stat_unixtime_filename "$f"

    done < <(find "$_dirpath_to_search" -xdev -type f -print0)
done | sort -k1 -n | cut -d' ' -f2-

exit 0
