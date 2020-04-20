#!/usr/bin/env python3

# Modifies file extensions based on the detected MIME-type.
# First written 2019-12-28 by <jonas@jonasjberg.com>

import argparse
import logging
import pathlib
import subprocess
import sys


sys.exit('TODO: WIP! Needs testing and further development!')


_SELF_BASENAME = pathlib.Path(__file__).name
LOG = logging.getLogger(_SELF_BASENAME)


USE_AS_IS = object()


def examine_application_octet_stream(filepath, mimetype):
    USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF = {
        '._.DS_Store',
        '.DS_Store',
        '.ICEauthority',
        '.viminfo',
        '.Xauthority',
        'DS_Store',
    }
    if filepath.name in USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF:
        return USE_AS_IS

    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        '3gp',
        'axx',
        'bin',
        'chm',
        'dat',
        'db',
        'img',
        'iso',
        'log',
        'mobi',
        'pak',
        'pdf',
        'pyc',
        'raw',
        'sqldb',
        'txt',
        'webarchive',
        'webm',
        'xml',
        'xps',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return None


def examine_application_x_dosexec(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'dll',
        'exe',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return None


def examine_application_xml(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'config',
        'plist',
        'props',
        'vcxproj',
        'xml',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'xml'


def examine_application_zip(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'jar',
        'xps',
        'zip',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return None


def examine_image_png(filepath, mimetype):
    USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF = {
        '.face',
    }
    if filepath.name in USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'png'


def examine_message_rfc_822(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'eml',
        'html',
        'mhtml',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return None


def examine_text_html(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'erb',
        'js',
        'py',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'html'


def examine_text_plain(filepath, mimetype):
    USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF = {
        '.bash_aliases',
        '.bash_eternal_history',
        '.bash_history',
        '.bash_logout',
        '.bash_profile',
        '.bashrc',
        '.environment',
        '.filetags',
        '.fzf.bash',
        '.gitconfig',
        '.gnuplot_history',
        '.gscan2pdf',
        '.gtk-bookmarks',
        '.gtk-recordmydesktop',
        '.ideavimrc',
        '.inputrc',
        '.lesshst',
        '.liquidpromptrc',
        '.mostrc',
        '.node_repl_history',
        '.nvidia-settings-rc',
        '.profile',
        '.selected_editor',
        '.sqlite_history',
        '.tmux.conf',
        '.vimrc',
        '.wget-hsts',
        '.Xdefaults',
        '.xinputrc',
        '.Xmodmap',
        '.xscreensaver',
        '.xsession-errors',
        'AUTHORS',
        'CHANGELOG',
        'ChangeLog',
        'COPYING',
        'FAQ',
        'MANIFEST.in',
        'README',
        'zshrc',
    }
    if filepath.name in USE_AS_IS_IF_BASENAME_EQUALS_ANY_OF:
        return USE_AS_IS

    if filepath.name.startswith('.'):
        return filepath.suffix

    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'acsm',
        'bash',
        'bib',
        'c',
        'cfg',
        'css',
        'csv',
        'desktop',
        'dic',
        'h',
        'html',
        'ini',
        'ipynb',
        'js',
        'json',
        'list',
        'log',
        'lua',
        'markdown',
        'md',
        'mht',
        'pl',
        'py',
        'raw',
        'rst',
        'rtf',
        'scss',
        'sh',
        'txt',
        'xml',
        'yaml',
        'yml',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    USE_AS_IS_IF_BASENAME_ENDSWITH_ANY_OF = {
        'description',
        'h.cmakein',
        'h.in',
        'info.json',
        'o.ur-safe',
        'pc.cmakein',
        'pc.in',
    }
    filepathstr = str(filepath)
    for ending in USE_AS_IS_IF_BASENAME_ENDSWITH_ANY_OF:
        if filepathstr.endswith(ending):
            return ending

    return 'txt'


def examine_text_troff(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'py',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return USE_AS_IS


def examine_text_x_c(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'c',
        'cpp',
        'h',
        'hpp',
        'markdown',
        'md',
        'rst',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'c'


def examine_text_x_cpp(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'c',
        'cpp',
        'h',
        'hpp',
        'md',
        'py',
        'rst',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'cpp'


def examine_text_x_python(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'md',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'py'


def examine_text_x_fortran(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'f',
        'F',
        'f03',
        'f90',
        'F90',
        'f95',
        'for',
        'txt',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'for'


def examine_video_mp4(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'm4v',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'mp4'


def examine_video_mpeg(filepath, mimetype):
    USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF = {
        'm4v',
        'mp4',
    }
    extension = str(filepath.suffix).lstrip('.')
    if extension in USE_AS_IS_IF_CURRENT_EXTENSION_EQUALS_ANY_OF:
        return USE_AS_IS

    return 'mpg'


IGNORED_MIMETYPES = {
    'inode/directory',
    'inode/x-empty',
}

# TODO: BUT we want to exclude ~/.python_history! So we need exclusion rules,
#       like "match this but ALSO DO NOT MATCH THIS" ..
MIMETYPE_EXTENSION_LOOKUP = {
    'application/CDFV2': 'db',
    'application/CDFV2-unknown': 'msg',
    'application/gzip': 'tar.gz',
    'application/java-archive': 'jar',
    'application/msword': 'doc',
    'application/octet-stream': examine_application_octet_stream,
    'application/ogg': 'ogg',
    'application/pdf': 'pdf',
    'application/vnd.debian.binary-package': 'deb',
    'application/vnd.ms-excel': 'xls',
    'application/vnd.ms-opentype': 'otf',
    'application/vnd.ms-powerpoint': 'ppt',
    'application/vnd.oasis.opendocument.presentation': 'odp',
    'application/vnd.oasis.opendocument.spreadsheet': 'ods',
    'application/vnd.oasis.opendocument.text': 'odt',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
    'application/x-7z-compressed': '7z',
    'application/x-bittorrent': 'torrent',
    'application/x-bzip2': 'tar.bz',
    'application/x-dosexec': examine_application_x_dosexec,
    'application/x-executable': USE_AS_IS,
    'application/x-font-ttf': 'ttf',
    'application/x-gzip': 'tar.gz',
    'application/x-lzma': 'lzma',
    'application/x-object': 'o',
    'application/x-rar': 'rar',
    'application/x-setupscript': 'ini',
    'application/x-sharedlib': USE_AS_IS,
    'application/x-shockwave-flash': 'swf',
    'application/x-tar': 'tar.gz',
    'application/x-xz': 'xz',
    'application/xml': examine_application_xml,
    'application/zip': examine_application_zip,
    'audio/mpeg': 'mp3',
    'audio/x-flac': 'flac',
    'audio/x-m4a': 'm4a',
    'audio/x-wav': 'wav',
    'image/gif': 'gif',
    'image/jpeg': 'jpg',
    'image/png': examine_image_png,
    'image/svg+xml': 'svg',
    'image/tiff': 'tif',
    'image/vnd.adobe.photoshop': 'psd',
    'image/vnd.djvu': 'djvu',
    'image/webp': 'webp',
    'image/x-icon': 'ico',
    'image/x-ms-bmp': 'bmp',
    'image/x-xcf': 'xcf',
    'message/rfc822': examine_message_rfc_822,
    'text/calendar': 'ics',
    'text/html': examine_text_html,
    'text/plain': examine_text_plain,
    'text/rtf': 'rtf',
    'text/troff': examine_text_troff,
    'text/vcard': 'vcf',
    'text/x-c': examine_text_x_c,
    'text/x-c++': examine_text_x_cpp,
    'text/x-fortran': examine_text_x_fortran,
    'text/x-makefile': USE_AS_IS,
    'text/x-python': examine_text_x_python,
    'text/x-ruby': 'rb',
    'text/x-shellscript': 'sh',
    'text/x-tex': 'tex',
    'video/mp4': examine_video_mp4,
    'video/mpeg': examine_video_mpeg,
    'video/ogg': 'ogg',
    'video/quicktime': 'mov',
    'video/x-flv': 'flv',
    'video/x-msvideo': 'avi',
}


def get_file_mimetype(filepath):
    completed_process = subprocess.run(
        ['file', '--mime-type', '--brief', '--', str(filepath)],
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )
    mimetype = completed_process.stdout.decode('utf-8').strip()
    return mimetype


def is_ignored_filepath(filepath):
    assert isinstance(filepath, pathlib.Path)
    return '.git' in filepath.parts or str(filepath.name) == '.gitignore'


def main(options):
    assert isinstance(options, dict)

    logging.basicConfig(
        format='%(name)s: %(levelname)-8.8s %(message)s',
        level=options.get('loglevel', logging.INFO),
    )

    for path in options['filepaths']:
        try:
            filepath = pathlib.Path(path).resolve()
        except FileNotFoundError:
            LOG.warning('Skipped unresolvable file: %s', path)
            continue

        if not filepath.is_file():
            LOG.debug('Ignored non-file: %s', filepath)
            continue

        if is_ignored_filepath(filepath):
            LOG.debug('Ignored filepath: %s', filepath)
            continue

        mimetype = get_file_mimetype(filepath)
        if mimetype in IGNORED_MIMETYPES:
            continue

        if mimetype not in MIMETYPE_EXTENSION_LOOKUP:
            LOG.warning(
                'Unhandled MIME-type %s from file: %s', mimetype, filepath
            )
            continue

        truth = MIMETYPE_EXTENSION_LOOKUP[mimetype]
        if callable(truth):
            truth = truth(filepath, mimetype)

        if truth is USE_AS_IS:
            LOG.info('Skipping file (use as-is): %s', filepath)
            continue

        if isinstance(truth, str):
            extension = truth
        else:
            LOG.error('Unhandled truth %r (MIME-type %s) from file: %s', truth, mimetype, filepath)
            continue

        if not extension:
            LOG.error('Got None truth (MIME-type %s) from file: %s', mimetype, filepath)
            continue

        if filepath.suffix[1:] == extension:
            LOG.info('Skipping file (final extension OK): %s', filepath)
            continue

        current_compound_suffixes = ''.join(filepath.suffixes).lstrip('.')
        if current_compound_suffixes == extension:
            LOG.info('Skipping file (compound extension OK) %s', filepath)
            continue

        LOG.info('Would have renamed: %s (%s) (extension=%s)', filepath, mimetype, extension)

    return True


def parse_args():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        prog=_SELF_BASENAME,
        usage='%(prog)s [options] [glob_pattern] [directories]',
    )
    parser.add_argument(
        'filepaths',
        help='files to process.',
        nargs='+',
        type=str,
    )
    parser.add_argument(
        '-v', '--verbose',
        action='count',
        default=0,
        dest='verbosity_level',
        help='Increase logging output verbosity.'
             ' Repeat for increasingly verbose output; "-v", "-vv", "-vvv".',
    )
    args = parser.parse_args()

    loglevel = {
        0: logging.ERROR,
        1: logging.WARNING,
        2: logging.INFO,
        3: logging.DEBUG,
    }.get(min(args.verbosity_level, 3), logging.ERROR)

    if not args.filepaths:
        parser.error('Argument filepaths must be one or more files')

    return {
        'filepaths': args.filepaths,
        'loglevel': loglevel,
    }


if __name__ == '__main__':
    options = parse_args()
    sys.exit(main(options))
