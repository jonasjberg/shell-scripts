#!/usr/bin/env bash

set -o errexit -o nounset -o noclobber


SLUGIFY_FILENAME_PATH="$(realpath -e -- ./slugify-filename)"
TESTFILE_GIVEN='foo - bar $∞£§ ___- + baz___.txt'
TESTFILE_EXPECT='foo_bar_baz.txt'


[ -x "$SLUGIFY_FILENAME_PATH" ] || exit 1
(
  cd /tmp || exit 1

  # Setup
  touch "$TESTFILE_GIVEN" || exit 1

  # Test
  if ! $("$SLUGIFY_FILENAME_PATH" "$TESTFILE_GIVEN")
  then
      echo 'FAIL (non-zero exit code)' ; exit 1 ;
  fi
  [ -f "$TESTFILE_EXPECT" ] && { echo PASS ; exit 0 ; } || { echo FAIL ; exit 1 ; }

  # Teardown
  [ -f "$TESTFILE_GIVEN"] && rm -v -- "$TESTFILE_GIVEN"
  [ -f "$TESTFILE_EXPECT"] && rm -v -- "$TESTFILE_EXPECT"
)
