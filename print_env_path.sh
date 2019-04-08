#!/usr/bin/env bash

# prettyprintPATH
# Print out entries in '$PATH' separated by newlines for easier reading.

printf '%s\n' "${PATH//:/$'\n'}"
