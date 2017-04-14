#!/usr/bin/env bash

#   fix-swedish-chars.sh
#   ####################
#   Copyright (c) 2017 Jonas Sjöberg
#   <http://www.jonasjberg.com>
#   <https://github.com/jonasjberg>
#
#   Recursively finds and renames files with swedish characters in the file
#   names (åäöÅÄÖ), starting from the specified path.  The starting path
#   defaults to the currnet working directory if left empty.
#
#   The purpose of this script is to work around problems when rsyncing from a
#   Linux system to MacOS.  Files with non-ASCII characters are encoded
#   differently and consequently deleted and transferred at every rsync
#   invocation.
#
#   Note that what might appear to be duplicate entries in the replacement
#   operations are in fact necessary, the characters are displayed just about
#   indentically but the underlying encodings stored in this source files is
#   different.
#
#   WARNING: This will NOT handle newlines in path/directory/file names safely.
#   __________________________________________________________________________
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   __________________________________________________________________________


set -e

searchpath="${1:-.}"


# TODO: Find returns a lot of files that contain non-printable ASCII characters
#       other than the swedish characters to be replace. This results in the
#       renaming operation source '$f' and destination '$fnew' being the same.
#       The "no clobber" flag '-n' used with 'mv' results in these operations
#       to simply print a warning and skip the file.

# TODO: Handle nesting better. The current approach does directories first,
#       then files.  Though this _might_ work, it is a hack fix at best.


# The find pattern matches all non-printable ASCII characters.
# Source:  http://unix.stackexchange.com/a/109753
LC_ALL=C find "$searchpath" -xdev -name '*[! -~]*' | while IFS='\n' read f
do
    # [ -f "$f" ] || continue
    # [ -d "$f" ] || continue

    fnew="${f/å/a}"
    fnew="${fnew/å/a}"
    fnew="${fnew/Å/A}"
    fnew="${fnew/Å/A}"
    fnew="${fnew/ä/a}"
    fnew="${fnew/ä/a}"
    fnew="${fnew/ä/a}"
    fnew="${fnew/Ä/A}"
    fnew="${fnew/Ä/A}"
    fnew="${fnew/Ä/A}"
    fnew="${fnew/ö/o}"
    fnew="${fnew/ö/o}"
    fnew="${fnew/Ö/O}"

    # echo "OLD: \"${f}\""
    # echo "NEW: \"${fnew}\""
    # echo ""

    mv -nvi -- "${f}" "${fnew}"
done

