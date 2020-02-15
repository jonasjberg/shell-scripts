#!/usr/bin/env bash

# clipboard_output.sh --- Fetches content from the Xorg server clipboard
# First written 2020-02-15 by <jonas@jonasjberg.com>

# This work is free. You can redistribute and/or modify it under the terms of
# the Do What The Fuck You Want To Public License. See http://www.wtfpl.net/
# for details.

set -o errexit -o noclobber -o nounset -o pipefail


_SELF_BASENAME="$(command basename -- "${BASH_SOURCE[0]}")"
readonly _SELF_BASENAME

print_error()
{
    printf '%s: ERROR: %s\n' "$_SELF_BASENAME" "$*" >&2
}

display_usage()
{
    command cat <<EOF

  $_SELF_BASENAME
  Fetches text content from the Xorg server clipboard.
  The content is written to standard output.

  Usage examples:

    $ $_SELF_BASENAME > clipboard_content.txt

  Note that the \$DISPLAY environment variable must
  be set to match the appropriate Xorg server.

EOF
}


if ! command -v xclip &>/dev/null
then
    print_error 'This script requires the "xclip" command. Exiting..'
    exit 127
fi

if [ -z "${DISPLAY:-}" ]
then
    # shellcheck disable=SC2016
    print_error 'The $DISPLAY environment variable is not set. Exiting..'
    exit 1
fi


if [ $# -ne 0 ]
then
    display_usage
    exit 0
fi


command xclip -out -selection clipboard
exit 0
