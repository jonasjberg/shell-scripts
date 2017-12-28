#!/usr/bin/env bash

# Copyright (c) 2017 jonasjberg
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2.
# See http://www.wtfpl.net/ for more details.

# List all files in a git repository by modification date,
# starting with the most recently modified.
# Based on https://serverfault.com/a/401450

set -o nounset -o errexit


git ls-tree -r --name-only HEAD \
| while read -r filename
do
    echo "$(git log -1 --date=iso-strict --format="%cd" -- "$filename") "$filename""
done | sort --reverse
