#!/bin/bash
# Generate folder manifest
# First written in 2015-05-10 by Jonas Sjöberg
# Last updated 2015-05-16

# Generates a txt file with the current directory path and contents.
# Created for dealing with Eagle backup-files (#00, #01, etc.) that are to be
# compressed to a .tar.gz or .tar.bz2 -archive.
# ------------------------------------------------------------------------------

# USER-DEFINED VARIABLES
# ==============================================================================
# Set the manifest filename
MANIFEST_FILENAME="manifest.lst"

#                  |  long iso format  |
#                  |  I.E. 2015-05-13  |
LSCOMMAND="ls -Flh --time-style=long-iso"
#              |||
#              ||+--- human readable sizes (e.g.,1K 234M 2G)
#              |+---- long listing
#              +----- append indicator (*/=>$|) to entries

FILECOMMAND="file -b"
#                  |
#                  +- do not prepend filenames to output lines (brief mode)
# ==============================================================================


# temporary files for intermediate storage
TEMPORARY_ROOT=$(mktemp -d)
TEMPORARY1=$(mktemp manifest.XXXXXX)
TEMPORARY2=$(mktemp manifest.XXXXXX)
# self-consciousness and to be cognizant
THIS_PROGRAM_NAME=$(basename $0)

# ------------------------------------------------------------------------------
# dothething() does the actual file creation
dothething(){
PATH_LOGICAL="$(cd $THIS_WORKING_PATH && pwd -L)"
PATH_PHYSICAL="$(cd $THIS_WORKING_PATH && pwd -P)"

cat << EOF > "$FULL_MANIFEST_PATH"
Folder manifest generated $(date +%F\ %H:%M:%S)
---------------------------------------------

Current logical path:  $PATH_LOGICAL
Current physical path: $PATH_PHYSICAL

Folder listing:

EOF

# .. end of header, now print the data
(printf "PERMISSIONS # OWNER GROUP SIZE DATE TIME NAME .\n" ; \
    $LSCOMMAND "$PATH_PHYSICAL" | sed 1d) | column -t > $TEMPORARY1

echo "" > $TEMPORARY2

# check mime filetype
for i in $THIS_WORKING_PATH/*; do
    $FILECOMMAND "$i" >> $TEMPORARY2
done

# concatenate columns
paste $TEMPORARY1 $TEMPORARY2 | column -t -s '	' >> "$FULL_MANIFEST_PATH"
}

# ------------------------------------------------------------------------------
# "main function"
# check whether the first parameter is a directory
if [[ -d "$@" ]]; then
    # OK! Our first parameter is a directory. Set working path.
    THIS_WORKING_PATH="$@"
    # Set manifest file destination relative to working path..
    FULL_MANIFEST_PATH="$THIS_WORKING_PATH/$MANIFEST_FILENAME"

    # Make sure we can write to the working path.
    if [[ -w "$THIS_WORKING_PATH" ]]; then
        # OK! We have write permissions.
        dothething
        exit
    else
        # Display error and die.
        echo "Error! Need write permissions to "$THIS_WORKING_PATH"!" >&2
        exit 1
    fi
else
    # Display usage and die.
    echo "Usage: $THIS_PROGRAM_NAME <directory>" >&2
    exit 1
fi

