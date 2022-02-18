#!/usr/bin/env python2

"""
Running this script like this:

    ./netcat_without_netcat.py 192.168.1.1 666

Should be basically equivalent to running netcat like this:

    nc -vzw 10 192.168.1.1 666

Written for Python 2 because reasons..
"""

from __future__ import print_function

import socket
import sys


def main(args):
    assert len(args) == 2, (
        'Expected two positional arguments; HOST/IPADDR and PORT'
    )
    host_or_ipaddr, portnumber = args

    socket.setdefaulttimeout(10)
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        client.connect((host_or_ipaddr, int(portnumber)))
        client.close()
    except socket.error as exc:
        print('Connection to %s:%s FAILED!' % (host_or_ipaddr, portnumber), file=sys.stderr)
        print(str(exc), file=sys.stderr)
        return 1

    print('Connection to %s:%s successful!' % (host_or_ipaddr, portnumber))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        sys.exit(1)
