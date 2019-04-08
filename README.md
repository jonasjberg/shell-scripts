shell-scripts
=============

Introduction
------------
This repo contains a subset of my *personal* yet still somehow public
collection of `*nix` shell-scripts and simple programs.


Disclaimer
----------
**WARNING:**
I take no responsability whatsoever for whatever might happen if you decide to
use these scripts, either as is or as modified versions.  You are on your own.


Listing
-------

| **Filename**                    | **Description**                                |
| ------------------------------- | ---------------------------------------------- |
| `add-mime-file-extension.sh`    | adds missing file extensions from MIME types   |
| `check-tex-syntax.sh`           | check syntax of LaTeX source file for errors   |
| `clampimgheight.sh`             | chop up images taller than a set max height    |
| `clipboard-to-file.sh`          | puts the clipboard contents in a file          |
| `congrep.sh`                    | "context-sensitive" grep options               |
| `convert-video-to-mp4.sh`       | converts videos to mp4 with `ffmpeg`           |
| `datedelta.py`                  | calculates years, months, days between dates   |
| `delete-macos-cruft.sh`         | find and delete MacOS junk                     |
| `exif-rename.sh`                | rename images from exif date/time              |
| `exiftooldate.sh`               | display date/time-information using `exiftool` |
| `expand_wordlist_encodings.sh`  | generates wordlists with different encodings   |
| `find_most_recently_modified_videos.sh` | find videos and sort by modify date            |
| `fix-redundant-paths.sh`        | find redundantly named files and directories   |
| `fix-permissions.sh`            | sets permissions recursively                   |
| `fix-swedish-chars.sh`          | rename files with "åäöÅÄÖ" in the file names   |
| `git-clone-username-dest.sh`    | clone git repo to custom destination path      |
| `git-last-modified.sh`          | list git repository files by modification date |
| `git-pull-recursively.sh`       | find and update git repos under a preset path  |
| `macbook-battery-logger.sh`     | generate MacBook laptop battery CSV statistics |
| `markdowngrep.py`               | find markdown headings in text given a pattern |
| `markdownify-telegram-log.py`   | reformat telegram messenger log file           |
| `markdowntoprettypdf.sh`        | `pandoc` wrapper with my favorite settings     |
| `notify`                        | `notify-send` functions                        |
| `prettyprintPATH`               | print entries in `$PATH` separated by `\n`     |
| `reencode-opx-video`            | reencodes videos with `ffmpeg` to save space   |
| `rename-macos-screenshot.py`    | used by MacOS Automator to rename screenshots  |
| `rotate-opx-video-90cw`         | rotates "OnePlus X" videos with `ffmpeg`       |
| `shrink-pdf.sh`                 | optimize pdf documents to use less disk space  |
| `slugify-filename`              | clean up file names                            |
| `today-dir`                     | creates a daily working directory symlink      |
| `vinetto_rename.py`             | rename files extracted with "vinetto"          |
| `wait-for-net.sh`               | loop and sleep until ping is successful        |
| `www2png`                       | convert a webpage to a image using `cutycapt`  |


Licensing
---------
Some files are licensed under the *GNU General Public License*, Version 2.
See `LICENSE_GPL.txt` or <http://www.gnu.org/licenses/> for the full license.

Other files are licensed under the *Do What The Fuck You Want To Public
License*, Version 2.  See `LICENSE_WTFPL.txt` or <http://www.wtfpl.net/>
for more details.

