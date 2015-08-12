#!/usr/bin/env bash

# check-tex-syntax    Runs syntax checks on TeX source code.
# ~~~~~~~~~~~~~~~~    Written in 2015 by Jonas Sjöberg for PRIVATE USE.

# LaCheck manpage info
# --------------------
# DESCRIPTION   LaCheck  is  a  general  purpose consistency checker for LaTeX
#               documents.  It reads a LaTeX document and displays warning
#               messages, if it finds bad sequences. It should be noted, that
#               the badness is very subjective.  LaCheck is designed to help
#               find common mistakes in LaTeX documents, especially those made
#               by beginners.
#
# chktex manpage info
# -------------------
# DESCRIPTION   chktex finds typographic errors in LaTeX
# AUTHOR        Jens T. Berger Thielemann

# ------------------------------------------------------------------------------
# make sure argument is present
if ! [[ ${1} && ${1+x} ]];
then
    echo "Check syntax of WHAT?" 1>&2
    echo "Usage: $0 <texsourcefile.tex>" 1>&2

    exit 1
fi

# make sure that chktex is available
if command -v "chktex" >/dev/null;
then
    echo -e "\n* Running 'chktex' on "${1}"\n"
    chktex --verbosity=2 "${1}"
    #chktex "${1}"
    echo -e "DONE!\n--------------------------------------------------"
else
    echo "Can not find chktex! Is it installed? Is it in your \$PATH?"
    exit 127
fi

# make sure that lacheck is available
if command -v "lacheck" >/dev/null;
then
    echo -e "\n\n* Running 'lacheck' on "${1}"\n"
    lacheck "${1}"
    echo -e "DONE!\n--------------------------------------------------"
else
    echo "Can not find lacheck! Is it installed? Is it in your \$PATH?"
    exit 127
fi


exit $?

