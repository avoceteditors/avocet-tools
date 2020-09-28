##############################################################################
# Copyright (c) 2020, Kenneth P. J. Dyer <kenneth@avoceteditors.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder nor the name of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
##############################################################################

# Module Imports
import pathlib

# Local Imports
from avocet.utils cimport files as fs

# Logger Configuration
from logging import getLogger
logger = getLogger(__name__)

cdef list eval_files(list files):
    """Evaluates the given files into specific file types 
    like RST and Markdown."""
    cdef list paths = []
    cdef object path

    # File Extensions
    cdef list rst = [".rst", '.restructuredtext']
    cdef list md = ['.md', '.markdown']
    cdef list xml = ['.xml', '.docbook']
    cdef list json = ['json']
    cdef list img = ['.png', '.jpeg', '.svg']

    # Iterate over Files from Argument
    for path in files:

        # Find reStructuredText File
        if path.suffix in rst:
            paths.append(fs.RSTSourceFileType(path))

        # Find Markdown File
        elif path.suffix in md:
            paths.append(fs.MDSourceFileType(path))

        # Find XML File
        elif path.suffix in xml:
            paths.append(fs.XMLSourceFileType(path))

        # Find JSON File
        elif path.suffix in json:
            paths.append(fs.JSONSourceFileType(path))

        # Find Image Resource File
        elif path.suffix in img:
            paths.append(fs.ImageResourceFileType(path))

        # Other Resource
        else:
            paths.append(fs.OtherResourceFileType(path))

    return paths
    
cdef list find(list sources, str wdir="."):
    """Receives list of source paths and working directory,
    returns list of files and files in directories for further
    analysis."""

    # Initialize Variables
    cdef list files = []
    cdef str src 
    cdef object path, sub_path

    # Set Default Sources
    if len(sources) == 0:
        sources = [wdir]

    # Iterate over Source Paths
    for src in sources:
        path = pathlib.Path(src)

        # Check if Path Exists
        if path.exists():

            if path.is_file():
                files.append(path)
            elif path.is_dir():
                for sub_path in path.rglob("*"):
                    files.append(sub_path)

        # Warn User on non-existent files
        else:
            logger.error(f"Received non-existent file argument: {src}")

    # Log Files
    logger.debug(f"Found {len(files)} files")

    # Return Value
    return eval_files(files)

cdef void run(object args):
    """Function used to run ``ls`` operations from the command-line"""
    logger.info("Called ls operation")

    cdef list paths = find(args.source, args.working_dir)
    cdef list clean_paths = []

    cdef fs.FileType path

    for path in paths:
        clean_paths.append(str(path))

    print("\n".join(clean_paths))
