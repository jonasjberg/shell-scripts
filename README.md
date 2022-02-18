shell-scripts
=============

Introduction
------------
This repo contains a subset of my *personal* yet still somehow public
collection of `*nix` shell-scripts and simple programs.


Disclaimer
----------
**WARNING:**
I take no responsibility whatsoever for whatever might happen if you decide to
use these scripts, either as is or as modified versions.  You are on your own.


Listing
-------

| **Filename**                            | **Description**                                         |
| --------------------------------------- | ------------------------------------------------------- |
| `add-mime-file-extension.sh`            | Adds missing file extensions from MIME types            |
| `clamp-image-height.sh`                 | Chop up images taller than a set max height             |
| `clipboard_input.sh`                    | Copies content to the Xorg server clipboard             |
| `clipboard_output.sh`                   | Fetches content from the Xorg server clipboard          |
| `congrep.sh`                            | "Context-sensitive" grep options                        |
| `convert-video-to-mp4.sh`               | Converts videos to mp4 with `ffmpeg`                    |
| `datedelta.py`                          | Calculates years, months, days between dates            |
| `delete-macos-cruft.sh`                 | Find and delete MacOS junk                              |
| `exif-rename.sh`                        | Rename images from exif date/time                       |
| `exiftooldate.sh`                       | Display date/time-information using `exiftool`          |
| `expand_wordlist_encodings.sh`          | Generates wordlists with different encodings            |
| `find-note.sh`                          | Combined grep with indexed search                       |
| `find_most_recently_modified_videos.sh` | Find videos and sort by modify date                     |
| `fix-permissions.sh`                    | Sets permissions recursively                            |
| `fix-redundant-paths.sh`                | Find redundantly named files and directories            |
| `fix-swedish-chars.sh`                  | Rename files with "åäöÅÄÖ" in the file names            |
| `git-clone-username-dest.sh`            | Clone git repo to custom destination path               |
| `git-last-modified.sh`                  | List git repository files by modification date          |
| `git-pull-recursively.sh`               | Find and update git repos under a preset path           |
| `git_pullff_all_remotes_push_all_remotes.sh` | Does "safe" synchronization with multiple Git remotes |
| `macbook-battery-logger.sh`             | Generate MacBook laptop battery CSV statistics          |
| `markdowngrep.py`                       | Find markdown headings in text given a pattern          |
| `markdownify-telegram-log.py`           | Reformat telegram messenger log file                    |
| `markdowntoprettypdf.sh`                | `pandoc` wrapper with my favorite settings              |
| `netcat_without_netcat.py`              | Trivial `netcat` work-alike for checking connectivity   |
| `prepend_relative_timestamp.py`         | Prepends relative timestamps to stdin.                  |
| `print_env_path.sh`                     | Print entries in `$PATH` separated by `\n`              |
| `record-desktop.sh`                     | Crude desktop video capture                             |
| `reencode-opx-video.sh`                 | Re-encodes videos with `ffmpeg` to save space           |
| `rename-macos-screenshot.py`            | Used by MacOS Automator to rename screenshots           |
| `rotate-opx-video-90cw.sh`              | Rotates "OnePlus X" videos with `ffmpeg`                |
| `run_command_on_git_revs.sh`            | Execute arbitrary shell commands over a range of Git revisions |
| `shrinkpdf.sh`                          | Optimize PDF documents to use less disk space           |
| `slugify-filename.sh`                   | Clean up file names                                     |
| `ssh_config_identity_files.sh`          | Checks if ~/.ssh/config SSH private key files exist     |
| `timestamped-tarball.sh`                | Creates `tar.lzma` archives with timestamped file names |
| `today-dir.sh`                          | Creates a daily working directory symlink               |
| `vinetto_rename.py`                     | Rename files extracted with "vinetto"                   |
| `wait-for-net.sh`                       | Loop and sleep until ping is successful                 |
| `www2png.sh`                            | Convert a webpage to a image using `cutycapt`           |
| `yamldiff.py`                           | Displays unified diffs of normalized YAML data          |


Licensing
---------
Some files are licensed under the *GNU General Public License*, Version 2.
See `LICENSE_GPL.txt` or <http://www.gnu.org/licenses/> for the full license.

Other files are licensed under the *Do What The Fuck You Want To Public
License*, Version 2.  See `LICENSE_WTFPL.txt` or <http://www.wtfpl.net/>
for more details.
