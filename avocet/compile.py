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
import latex
import pathlib
import yaml
import re
import subprocess
import shutil
from wordcloud import WordCloud

# Local Imports
from avocet import common

# Logger
from logging import getLogger
logger = getLogger()

# Chapter
chap_pattern = re.compile("^\\\\chapter\\*\{.*?\}|^\\\\chapter\{.*?\}")

######################### RUN MAIN PROCESS ###################################
def run(args):
    """RUns the main process"""
    logger.info("Called compile operation")

    with open(args.source, "r") as f:
        config = yaml.load(f.read(), Loader=yaml.SafeLoader)

    # Configure Source and Output
    logger.debug("Configuring source and output directories")
    cwd = pathlib.Path(args.source).parent
    config["source"] = cwd.joinpath(config.get("source", "src"))
    config["output"] = cwd.joinpath(config.get("output", "build"))
    config["cwd"] = cwd
    if not config["source"].exists():
        logger.warn(f"Invalid source path: {config['source']}")
        return 1
    if not config["output"].exists():
        logger.debug(f"Creating output directory: {config['output']}")
        config["output"].mkdir(parents=True)

    if args.lexica == None:
        args.lexica = config["source"].joinpath("lexica")
    else:
        args.lexica = pathlib.Path(args.lexica)

    if not args.lexica.exists():
        args.lexica.mkdir(parents=True)
    config["lexica"] = args.lexica

    # Generate Lexica
    common.gen_lexica(config)

    # Fetch Source
    src = common.get_source(config)

    # Output
    logger.debug("Prepare output")
    texdir = config["output"].joinpath("tex")
    pdfdir = config["output"].joinpath("pdf")
    if not texdir.exists():
        logger.debug("Creating build tex directory")
        texdir.mkdir(parents=True)
    if not pdfdir.exists():
        pdfdir.mkdir(parents=True)

    output = []
    
    if args.all:
        for k, tex in src.texfiles.items():
            if tex.document:
                texpath = texdir.joinpath(f"{tex.name}.tex")
                base_pdfpath = texdir.joinpath(f"{tex.name}.pdf")
                pdfpath = pdfdir.joinpath(f"{tex.name}.pdf")

                output.append((texpath, pdfpath, base_pdfpath, tex.text))
            elif len(re.findall(chap_pattern, tex.text)) > 0 and args.chapters: 
                texpath = texdir.joinpath(f"chapter-{tex.name}.tex")
                base_pdfpath = texdir.joinpath(f"chapter-{tex.name}.pdf")
                pdfpath = pdfdir.joinpath(f"chapter-{tex.name}.pdf")

                text = common.process_chapter(src, tex, texdir)
                output.append((texpath, pdfpath, base_pdfpath, text))
    else:
        mtime = 0
        texkey = None
        for k, tex in src.texfiles.items():
            if tex.document:
                if tex.mtime > mtime:
                    mtime = tex.mtime
                    texkey = k

        tex = src.texfiles[texkey]
        texpath = texdir.joinpath(f"{tex.name}.tex")
        base_pdfpath = texdir.joinpath(f"{tex.name}.pdf")
        pdfpath = pdfdir.joinpath(f"{tex.name}.pdf")
        output.append((texpath, pdfpath, base_pdfpath, tex.text))


    # Write TeX Files
    chap_file = re.compile("^chapter-.*?")
    for (path, pdfpath, base_pdfpath, text) in output:

        logger.debug(f"Writing: {str(path)}")
        with open(path, "w") as f:
            f.write(text)

        base_text = subprocess.check_output(["detex", "-e", "titlepage", str(path)]).decode()

        if args.all and not args.no_latex:
            # Generate Chapter Wordclouds
            if re.match(chap_file, path.stem):
                img_path = path.parent.joinpath(f"{path.stem}-cloud.png")

                wc = WordCloud()
                wc.mode = "RGBA"
                wc.colormap = "gray"
                wc.background_color = None
                wc.generate(base_text)
                img = wc.to_image()
                with open(img_path, "wb") as f:
                    img.save(f, format="png", optimize=True)

            # Run LuaLaTeX
            subprocess.run(["lualatex", f"--output-directory={str(path.parent)}", str(path)])
            shutil.copyfile(base_pdfpath, pdfpath)
        elif not args.no_latex:
            subprocess.run(["lualatex", f"--output-directory={str(path.parent)}", str(path)])
            shutil.copyfile(base_pdfpath, pdfpath)

