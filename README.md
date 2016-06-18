shell-scripts
=============

Introduction
------------
This repo contains a subset of my *personal* yet still somehow public
collection of `*nix` shell-scripts.


Listing
-------

| **Filename**                | **Description**                                |
| --------------------------- | ---------------------------------------------- |
| `check-tex-syntax`          | check syntax of LaTeX source file for errors   |
| `clampimgheight`            | chop up images taller than a set max height    |
| `clipboard-to-file`         | puts the clipboard contents in a file          |
| `convert-video-to-mp4`      | converts videos to mp4 with `ffmpeg`           |
| `crop-instagram-screenshot` | crop images to size                            |
| `datedelta`                 | calculates years, months, days between dates   |
| `exif-rename`               | rename images from exif date/time              |
| `exiftooldatel`             | display date/time-information using `exiftool` |
| `fix-permissions`           | sets permissions recursively                   |
| `folder-manifest`           | generate txt file with folder info             |
| `git-backup`                | recursively find and backup git repos          |
| `git-recursive-pull`        | recursively find repos and do `git pull`       |
| `notify`                    | `notify-send` functions                        |
| `prettyprintPATH`           | print entries in `$PATH` separated by `\n`     |
| `pull-from`                 | `rsync` wrapper for synchronizing directories  |
| `shrink-pdf`                | optimize pdf documents to use less disk space  |
| `slugify-filename`          | clean up file names                            |
| `slugify-filename-test`     | unit tests for `slugify-filename`              |
| `src2tex`                   | convert source code to LaTeX                   |
| `tex2pdf`                   | convert LaTeX to pdf                           |
| `timestampdashes`           | rename files to `YYYY-MM-DD_hh-mm-ss.ext`      |
| `timestampdashes-test`      | unit tests for `timestampdashes`               |
| `vrml2png`                  | generate png previews of vrml 3D models        |
| `www2png`                   | convert a webpage to a image using `cutycapt`  |


Disclaimer
----------
**WARNING:**
I take no responsability whatsoever for whatever might happen if you decide to
use these scripts, either as is or as modified versions.  You are on your own.

**Please handle with CARE!**

Don't look at this repository for guidance or reference.  There are great free
resources for properly learning shell scripts, like for instance;

* [Bash Guide for Beginners](http://tldp.org/LDP/Bash-Beginners-Guide/html/)
  by Machtelt Garrels
* [Advanced Bash-Scripting Guide](http://www.tldp.org/LDP/abs/html/)
  by Mendel Cooper


License
-------
GNU GPL, Version 2.  See '`LICENSE.txt`' for the full license.
