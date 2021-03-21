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

# Module Import
import avocet.compile
import dion.tex
import shutil
import subprocess
import sys

# Configure Logger
from logging import getLogger
logger = getLogger()

############################# RUN COMMAND #####################################
def run(args):
    """ Runs the compile process as called from the command-line."""
    logger.info("Called the compile command")

    documents = []
    for path, data in args.config.src.data_tex.items():
        if data.is_doc:
            data.compile(args.config.src)
            documents.append(data)

    # Exit if None
    if len(documents) == 0:
        logger.error("No documents foudn in source tree to compile")
        sys.exit(1)

    # Reduce if not building all
    if not args.all:
        target = documents[0]

        for doc in documents:
            if doc.lastmod() > target.lastmod():
                target = doc
        documents = [target]

    for doc in documents:
        dion.tex.render_lexica(doc, args.config)

        # Configure Paths
        tex_path = args.config.output_latex.joinpath(doc.path.name)
        tmp_path = args.config.output_latex.joinpath(f"{doc.path.stem}.pdf")
        pdf_path = args.config.output_pdf.joinpath(f"{doc.path.stem}.pdf")

        with open(tex_path, "w") as f:
            f.write(doc.content)

        if not args.no_latex:
            subprocess.run([args.engine, f'--output-directory={str(args.config.output_latex)}', str(tex_path)])

            shutil.copyfile(tmp_path, pdf_path)






        

