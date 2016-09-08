#!/usr/bin/env bash

# http://www.alfredklomp.com/programming/shrinkpdf
# Licensed under the 3-clause BSD license:
#
# Copyright (c) 2014, Alfred Klomp
# All rights reserved.
#
# Modified february 2016 by Jonas Sjöberg
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

IMAGE_RESOLUTION=150
PERCENT_THRESHOLD=10

function shrink()
{
  gs                                           \
    -q -dNOPAUSE -dBATCH -dSAFER               \
    -sDEVICE=pdfwrite                          \
    -dCompatibilityLevel=1.4                   \
    -dPDFSETTINGS=/screen                      \
    -dEmbedAllFonts=true                       \
    -dSubsetFonts=true                         \
    -dAutoRotatePages=/None                    \
    -dDownsampleColorImages=true               \
    -dColorImageDownsampleType=/Bicubic        \
    -dColorImageResolution=${IMAGE_RESOLUTION} \
    -dGrayImageDownsampleType=/Bicubic         \
    -dGrayImageResolution=${IMAGE_RESOLUTION}  \
    -dMonoImageDownsampleType=/Bicubic         \
    -dMonoImageResolution=${IMAGE_RESOLUTION}  \
    -sOutputFile="$2"                          \
    "$1"
}

function check_smaller()
{
  # If $1 and $2 are regular files, we can compare file sizes to
  # see if we succeeded in shrinking. If not, we copy $1 over $2:
  if [ ! -f "$1" -o ! -f "$2" ]; then
      return 0;
  fi

  ISIZE=$(du -k "$1" | cut -f1)
  OSIZE=$(du -k "$2" | cut -f1)
  
  percentage=$(echo "scale=2; ($OSIZE - $ISIZE)/$ISIZE * 100" | bc)

  TAB='  '
  SEP=': '
  FORMAT="${TAB}%-7.7s%-50.50s${SEP}%-12d\n"
  printf "\n%s\n" 'File size (1K blocks):'
  printf "$FORMAT" "input"  "(${1})" "$ISIZE"
  printf "$FORMAT" "output" "(${2})" "$OSIZE"
  printf "${TAB}%-7.7s%-50.50s${SEP}%-6.6s\n" "ratio" "(approximate)" "${percentage}%"


  if [ "$ISIZE" -le "$OSIZE" ]; then
    printf "\n%-30.30s\n" "[ABORT] input is <= output .." >&2
    rm -v -- "$2"
    return
  fi

  percentage=${percentage//-}
  percentage=${percentage%%.*}
      
  if [ "$percentage" -gt "$PERCENT_THRESHOLD" ]; then
    printf "\n%-30.30s\n" "[ OK! ] above ${PERCENT_THRESHOLD}% threshold."
    mv -v -- "$2" "$1"
  else
    printf "\n%-30.30s\n" "[ABORT] ratio below threshold .." >&2
    rm -v -- "$2"
  fi
}

function main()
{
  origfile="$1"

  # Need an input file:
  if [ ! -f "$origfile" ]; then
    echo "$origfile is not a file. Aborting .." >&2
    return 1
  fi

  #echo "processing \"$origfile\""

  resultfile="${origfile%.*}_tmp.pdf"

  if [ -e "$resultfile" ]; then
    echo "$resultfile already exists and would be overwritten. Aborting .." >&2
    return 1
  fi

  shrink "$origfile" "$resultfile" || return
  check_smaller "$origfile" "$resultfile"

  echo ""
}

if [ $# -eq 0 ]
then
  echo "Positional arguments missing! At least one is required." >&2
  exit 1
else
  for arg in "$@"
  do
    main "${arg}"
  done
fi

exit $?
