#!/usr/bin/env bash
#                                                2016-2018 Jonas Sjöberg
#                                              http://www.jonasjberg.com
#                                          https://github.com/jonasjberg
#   ====================================================================
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#                   (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#               GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>
#   ====================================================================

set -o noclobber -o nounset -o pipefail -o errexit

SELF_BASENAME="$(basename $0)"


if ! man xargs | col -b | grep -q -- '--no-run-if-empty' >/dev/null 2>&1
then
    cat >&2 <<EOF

  WARNING:  This script requires a version of xargs that implements
            the GNU extension option '-r', '--no-run-if-empty'.
            Aborting ..                      (TODO: Add workaround)

EOF
    exit 1
fi

if [ "$#" -ne 1 ] || [ ! -d "$1" ]
then
    cat >&2 <<EOF

  USAGE:  ${SELF_BASENAME} [PATH]

  The given [PATH] is searched recursively for MacOS "cruft".

  Basename     MIME-type                           Filesize
  --------     ---------                           --------
  .DS_Store    Apple Desktop Services Store        any
  ._*          AppleDouble encoded Macintosh file  4096 bytes
  ._*          AppleDouble encoded Macintosh file  any

  Files matching any of the above requirements are deleted.

  The last requirement row might cause data loss (?)
  TODO: Look into cleaning up with 'dot_clean' on MacOS.

  NOTE:  There are no confirmation prompts! rm is forever!

EOF

    exit 0
fi


get_absolutely_real_path()
{
    sort -z | xargs --no-run-if-empty -0 realpath -e -z
}

uncruftify()
{
    # printf 'Found cruft:  "%s"\n' "$1"
    rm -v -- "$1"
}


# TODO: Deduplication worth the hassle that is bash functions and multi-word arguments?
while IFS= read -r -d '' _abspath
do
    [ -f "$_abspath" ] || continue

    case $(file --brief -- "$_abspath") in
        'Apple Desktop Services Store') uncruftify "$_abspath" ;;
                                     *) continue ;;
    esac
done < <(find "$1" -xdev -type f -name '.DS_Store' -print0 | get_absolutely_real_path)


# TODO: Deduplication worth the hassle that is bash functions and multi-word arguments?
while IFS= read -r -d '' _abspath
do
    [ -f "$_abspath" ] || continue

    case $(file --brief -- "$_abspath") in
        'AppleDouble encoded Macintosh file') uncruftify "$_abspath" ;;
                                           *) continue ;;
    esac
done < <(find "$1" -xdev -type f -name '._*' -size 4096c -print0 | get_absolutely_real_path)


# TODO: Deduplication worth the hassle that is bash functions and multi-word arguments?
# TODO: This might cause data loss (?)
# TODO: Look into using 'dot_clean' on MacOS to join resource fork and data fork (?)
while IFS= read -r -d '' _abspath
do
    [ -f "$_abspath" ] || continue

    case $(file --brief -- "$_abspath") in
        'AppleDouble encoded Macintosh file') uncruftify "$_abspath" ;;
                                           *) continue ;;
    esac
done < <(find "$1" -xdev -type f -name '._*' -print0 | get_absolutely_real_path)
