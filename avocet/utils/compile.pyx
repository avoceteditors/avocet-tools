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
import sys

# Local Imports
from avocet.xml cimport compile as xml_compile

# Configure Logger
from logging import getLogger
logger = getLogger(__name__)

cdef void run(object args):
    """Runs main process called from command-line"""
    logger.info("Called compile operation")

    src = pathlib.Path(args.source)
    bld = pathlib.Path(args.output)

    if src.exists():

        if src.is_file():
            if src.suffix in [".xml", ".docbook", ".dion"]:
                logger.debug("Compiling XML File")

                bld = bld.joinpath("xml")
                if not bld.exists():
                    logger.info(f"Creating output directory: {str(bld)}")
                    bld.mkdir(parents=True)

                xml_compile(src, bld, args.quotes)

            else:
                logger.warning(f"Unknown file type {src.suffix}")
        elif src.is_dir():
            logger.critical("Avocet currently does not support compiling directories")
            sys.exit(1)
    else:
        logger.critical("Non-existent source path")
        sys.exit(1)
