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
import dion
import dion.yml
import os.path
import sys
import wulfila.lang


# Configure Logger
from logging import getLogger
logger = getLogger()

class Config:

    def __init__(self, path):
        self.cwd = path
        self.registry = wulfila.lang.Registry()
        data = dion.yml.read(path.joinpath("project.yml"), True)

        # Set Paths
        self.source = self.cwd.joinpath(data.get("source", "src")).resolve()
        self.output = self.cwd.joinpath(data.get("output", "build")).resolve()
        self.output_latex = self.output.joinpath("latex")
        self.output_pdf = self.output.joinpath("pdf")

        for i in [self.output, self.output_latex, self.output_pdf]:
            if not i.exists():
                i.mkdir(parents=True)

        self.src = dion.Source(self.source, self.registry)

        self.src.update_registry()

    def __repr__(self):
        src = str(os.path.relpath(self.source, self.cwd))
        out = str(os.path.relpath(self.output, self.cwd))

        return " ".join([
            f"<{self.__class__.__name__}",
            f'path="{self.cwd}"',
            f'source="{src}"',
            f'output="{out}"',
            f'file_count={self.src}',
            f'registry={list(self.registry.langs.values())}',
            "/>"
        ])


def find_root(path):
    project = path.joinpath("project.yml")

    try:
        if project.exists():
            return Config(path)
        else:
            return find_root(path.parent)
    except Exception as e:
        logger.error(f"Invalid working directroy: {e}")
        sys.exit(1)

