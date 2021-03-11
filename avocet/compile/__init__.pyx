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
# Module IMports
import subprocess
import shutil

# Local Imports
from avocet.config cimport Config, find_root
from avocet.source cimport LaTeXData, SourceData, ResourceData
from avocet.compile cimport tex
from avocet.compile cimport yml
from avocet.document cimport Document, LaTeXDocument

# Logger Configuration
from logging import getLogger
logger = getLogger()

############################## RUN MAIN PROCESS ###############################
cpdef void run(args):
    """ Runs the main compile operation """
    logger.info("Called compile operation")
    cdef Document doc
    cdef list docs = []
    cdef dict langs = {}

    cdef Config config = find_root(args.working_dir)

    logger.info("Read source")
    for lib in [config.src.data_latex, config.src.data_yaml] :

        # Load Text into File
        for key, data in lib.items():
            if isinstance(data, SourceData):
                data.read()

    # Prepare Languages
    logger.info("Processing data")
    for path, data in config.src.data_yaml.items():
        if "language" in data.data:
            key = data.data["language"]
            yml.load(key, data.data, langs)

    # Find LaTeX Documents 
    logger.info("Build Documents")
    for key, data in config.src.data_latex.items():
        if tex.is_doc(data):
            tex.build(data, config.src.data_latex, langs)
            doc = LaTeXDocument(data) 
            docs.append(doc)

    # Prepare Output
    logger.info("Initialize output directories")
    outdir_latex = config.output_latex
    outdir_pdf = config.output_pdf


    logger.info("Writing LaTeX output")

    cdef list cmd = ["lualatex", f"--output-directory={str(outdir_latex)}"]

    for doc in docs:
        out_latex = outdir_latex.joinpath(doc.filename)
        out_tmp = outdir_latex.joinpath(doc.pdf_filename)
        out_pdf = outdir_pdf.joinpath(doc.pdf_filename)

        with open(out_latex, "w") as f:
            f.write(doc.text)

        logger.info("Running LaTeX")
        subprocess.run(cmd + [out_latex])
        shutil.copyfile(out_tmp, out_pdf)




