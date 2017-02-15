#!/usr/bin/env bash
  
# markdowntoprettypdf.sh
# ~~~~~~~~~~~~~~~~~~~~~~
# Copyright 2016-2017 by Jonas Sjöberg
# http://www.jonasjberg.com
# https://github.com/jonasjberg
# jomeganas[AT]gmail[DOT]com
#
# Pandoc wrapper that uses my favorite settings, also adds some error checking.
# ______________________________________________________________________________
#
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
# ______________________________________________________________________________


markdowntoprettypdf() 
{
    src="$1"
    dest="${1}.pdf"

    # Do character replacements before piping to pandoc.
    cat "$src" | sed 's/➡/-->/' | \
    pandoc --smart --normalize --standalone \
           --highlight-style=monochrome \
           --variable mainfont="DejaVu Sans" \
           --variable monofont="DejaVu Sans Mono" \
           --variable fontsize=11pt \
           --variable geometry:"top=1.5cm, bottom=2.5cm, left=1.5cm, right=1.5cm" \
           --variable geometry:a4paper \
           --table-of-contents \
           --toc-depth=4 \
           --number-sections \
           -f markdown \
           -o "$dest"
}


if [ "$#" -eq 0 ]
then
    echo "USAGE: \"$(basename $0) [FILE]...\""
    echo ""
    echo "Where [FILE] is one or more text files written in markdown syntax,"
    echo "suitable for use with \"pandoc\"."
    exit 1
else
    for arg in "$@"
    do
        arg="$(readlink -m -- "$arg")"
        if [ ! -r "$arg" ]
        then
            echo "Not a readable file: \"${arg}\""
            continue
        else
            case "$arg" in
            *.markdown | *.md )
                echo "Processing file \"${arg}\" .." ;
                markdowntoprettypdf "$arg" ;;
            *)
                echo "Skipping: \"${arg}\"" ;;
            esac
        fi
    done
fi


exit $?
