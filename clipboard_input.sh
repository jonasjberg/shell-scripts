#!/usr/bin/env bash

# clipboard_input.sh --- Copies content to the Xorg server clipboard
# First written 2020-02-12 by <jonas@jonasjberg.com>

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

print_usage()
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


if ! [ -t 0 ]
then
    # File descriptor 0 is NOT opened on a terminal. Read from stdin.
    printf '%s\n' "$(< /dev/stdin)" | command xclip -selection clipboard
    exit 0
fi


# File descriptor 0 is opened on a terminal. Try to read from a file.
if [ $# -ne 1 ]
then
    print_usage
    exit 0
fi

maybe_filepath="$1"
if ! {
    [ -e "$maybe_filepath" ] &&
    filepath="$(
        command realpath --canonicalize-existing -- "$maybe_filepath"
    )"
}
then
    print_error 'File does not exist:' "$maybe_filepath"
    exit 1
fi

case $(command file --mime-type --brief -- "$filepath") in
    text/*)
        # OK! Do nothing, keep going.
        ;;
    *)
        print_error 'File does not appear to be a text file:' "$filepath"
        exit 1
        ;;
esac

command xclip -in -selection clipboard "$filepath"
exit 0
