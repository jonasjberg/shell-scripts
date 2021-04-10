#!/usr/bin/env python3
"""
Reads lines from stdin, prepends timestamps to each line and writes the
timestamped line to stdout. Timestamp is time elapsed since this script
started up (roughly but good enough for 1 second precision).

Example usage:

  $ { echo foo; sleep 2; echo bar; sleep 1; echo baz; } |
  ~/path/prepend_relative_timestamp.py
  00:00 foo
  00:01 bar
  00:02 baz

Based on (stolen from) commit 5078a0baa26e0eb715e86c93ec32af6bc4022e45 of this:
https://github.com/ansible/ansible.git:.azure-pipelines/scripts/time-command.py

Modified to drop Python 2 compatibility, along with minor trivial tweaks.
"""

import sys
import time


def main(stdin_=sys.stdin, stdout_=sys.stdout):
    start_time_seconds = time.time()

    stdin_.reconfigure(errors='surrogateescape')
    stdout_.reconfigure(errors='surrogateescape')

    for line in stdin_:
        elapsed_secs = int(time.time() - start_time_seconds)
        elapsed_mins, elapsed_secs = divmod(elapsed_secs, 60)

        stdout_.write('{:02}:{:02} {!s}'.format(
            elapsed_mins,
            elapsed_secs,
            line,
        ))
        stdout_.flush()


if __name__ == '__main__':
    main()
