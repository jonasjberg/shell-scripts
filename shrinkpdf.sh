#!/usr/bin/env bash

# http://www.alfredklomp.com/programming/shrinkpdf
# Licensed under the 3-clause BSD license:
#
# Copyright (c) 2014, Alfred Klomp
# All rights reserved.
#
# Modified february 2016 by Jonas Sjöberg
# Modified and extended 2017 by Jonas Sjöberg
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

set -o noclobber -o nounset -o pipefail


IMAGE_RESOLUTION=150     # Resample images (dpi)
PERCENT_THRESHOLD=50     # Skip if size difference is lower (%)


C_RED="$(tput setaf 1)"
C_GRN="$(tput setaf 2)"
C_RES="$(tput sgr0)"

print_usage()
{
    cat <<EOF
         $SELF  ::  Decrease file size of PDF documents.

  Usage: $SELF [FILES..]

         FILES: The PDF file(s) to process.
                Filetype is verified by reading the "magic" bytes.

         Any valid PDFs are processed with Ghostscript to rebuild the
         file and perform lossy recompression of the contents.
         Any images are downsampled to ${IMAGE_RESOLUTION}dpi.

         If the processing is successful and the size of the processed
         file is at least ${PERCENT_THRESHOLD}% of the original file
         size, the original file is replaced with the processed file.

         The file is skipped if the processing is unsuccessful.
         The file is skipped if the size of the processed file file
         size changed less than ${PERCENT_THRESHOLD}%.

         For example, given the change;   Input    Output   Ratio
                                          448201   65161    -85.00%

         If 'PERCENT_THRESHOLD=75', the original would be replaced.


Example: $SELF /tmp/gibson-rules.pdf ~/temp/*.pdf

EOF
}

run_ghostscript()
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

replace_if_size_delta_over_threshold()
{
    # If $1 and $2 are regular files, we can compare file sizes to
    # see if we succeeded in shrinking. If not, we copy $1 over $2:
    if [ ! -f "$1" -o ! -f "$2" ]
    then
        return 0
    fi

    ISIZE="$(du -bk "$1" | cut -f1)"
    OSIZE="$(du -bk "$2" | cut -f1)"

    percentage="$(echo "scale=2; ($OSIZE - $ISIZE)/$ISIZE * 100" | bc)"

    TAB='  '
    SEP=': '
    FORMAT="${TAB}%-7.7s%-50.50s${SEP}%-12d\n"
    printf "%-28.28s %-12.12s %-12.12s %-8.8s\n" 'File Size (1K blocks)' 'Before' 'After' 'Ratio'
    printf "%-28.28s %-12.12s %-12.12s %-8.8s\n" ' ' "$ISIZE" "$OSIZE" "${percentage}%"

    if [ "$ISIZE" -le "$OSIZE" ]; then
        printf "%s\n" "[ABORT] Input size <= Output size .." >&2
        rm -v -- "$2"
        return
    fi

    percentage="${percentage//-}"
    percentage="${percentage%%.*}"

    if [ "$percentage" -gt "$PERCENT_THRESHOLD" ]; then
        printf "%s\n" "${C_GRN}[WRITING]${C_RES} Size ratio exceeds ${PERCENT_THRESHOLD}% threshold"
        mv -v -- "$2" "$1"
    else
        printf "%s\n" "${C_RED}[SKIPPED]${C_RES} Size ratio below ${PERCENT_THRESHOLD}% threshold"
        rm -v -- "$2"
    fi
}

main()
{
    local origfile="$1"
    local resultfile

    if [ ! -f "$origfile" ]
    then
        echo "${C_RED}[SKIPPED]${C_RES} Not a file: \"${origfile}\"" >&2
        return 1
    fi

    # Verify file type by reading magic header bytes.
    if [ ! "$(file --mime-type --brief -- "$origfile")" == 'application/pdf' ]
    then
        echo "${C_RED}[SKIPPED]${C_RES}Not a PDF document: \"${origfile}\"" >&2
        return 1
    fi


    echo "Processing file: \"${origfile}\""

    resultfile="${origfile%.*}_tmp.pdf"

    if [ -e "$resultfile" ]; then
        echo "$resultfile already exists and would be overwritten. Aborting .." >&2
        return 1
    fi

    if run_ghostscript "$origfile" "$resultfile"
    then
        replace_if_size_delta_over_threshold "$origfile" "$resultfile"
    else
        echo "${C_RED}[ERROR]${C_RES} Skipping \"${origfile}\" .."
    fi

    echo ""
}

if [ "$#" -eq "0" ]
then
    print_usage
    exit 1
else
    for arg in "$@"
    do
        main "$arg"
    done
fi

exit $?
