#!/usr/bin/env bash

# clipboard_input.sh --- Copies content to the Xorg server clipboard
# First written 2020-02-12 by <jonas@jonasjberg.com>

# This work is free. You can redistribute and/or modify it under the terms of
# the Do What The Fuck You Want To Public License. See http://www.wtfpl.net/
# for details.

set -o errexit -o noclobber -o nounset -o pipefail


_SELF_BASENAME="$(command basename -- "${BASH_SOURCE[0]}")"
readonly _SELF_BASENAME


if ! command -v xclip &>/dev/null
then
    printf '%s: CRITICAL: This script requires the "xclip" command. Exiting..\n' "$_SELF_BASENAME"
    exit 1
fi

if [ -z "${DISPLAY:-}" ]
then
    printf '%s: ERROR: The $DISPLAY environment variable is not set. Exiting..\n' "$_SELF_BASENAME"
    exit 1
fi


display_usage()
{
    command cat <<EOF

  $_SELF_BASENAME
  Copies text content to the Xorg server clipboard.
  The input is read from either standard input or a
  file path given as a positional argument.

  Usage examples:

    $ $_SELF_BASENAME [FILEPATH]
    $ grep foobar data.txt | $_SELF_BASENAME

  Note that the \$DISPLAY environment variable must
  be set to match the appropriate Xorg server.

EOF
}


if ! [ -t 0 ]
then
    # File descriptor 0 is NOT opened on a terminal. Read from stdin.
    printf '%s\n' "$(< /dev/stdin)" | command xclip -selection clipboard
    exit 0
fi


# File descriptor 0 is opened on a terminal. Read from a file.
if [ $# -ne 1 ]
then
    display_usage
    exit 0
fi

if ! [ -e "$1" ]
then
    printf '%s: WARNING: File does not exist: %s\n' "$_SELF_BASENAME" "$1"
    exit 1
fi

if ! argabspath="$(command realpath --canonicalize-existing -- "$1")"
then
    printf '%s: WARNING: File does not exist: %s\n' "$_SELF_BASENAME" "$1"
    exit 1
fi

case $(command file --mime-type --brief -- "$argabspath") in
    text/*)
        # OK! Do nothing, keep going.
        ;;
    *)
        printf '%s: WARNING: File does not appear to be a text file: %s\n' "$_SELF_BASENAME" "$argabspath"
        exit 1
        ;;
esac

command xclip -in -selection clipboard "$argabspath"
exit $?
