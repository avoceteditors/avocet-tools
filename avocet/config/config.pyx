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
import os.path 
import yaml

# Local Imports
from avocet.source cimport Source

# Logger Configuration
from logging import getLogger
logger = getLogger()

cdef class Config:
    
    def __init__(self, path):
        self.cwd = path

        with open(path.joinpath("project.yml"), "r") as f:
            data = yaml.load(f.read(), Loader=yaml.SafeLoader)

        self.set_paths(data)

        if path.stat().st_mtime > self.source.stat().st_mtime:
            logger.debug("Source directory more up to date")
            self.src = Source(self.source)
        else:
            logger.debug("Project directory more up to date")
            self.src = Source(self.source)

    def set_paths(self, data):
        """Configures paths for Config"""

        # Configure Cache
        self.cache = self.cwd.joinpath(".avocet")
        if not self.cache.exists():
            self.cache.mkdir(parents=True)

        self.cache_source = self.cache.joinpath("source.db").resolve()

        self.source = self.cwd.joinpath(data.get("source", "src")).resolve()
        self.output = self.cwd.joinpath(data.get("output", "build")).resolve()
        self.output_latex = self.output.joinpath("latex")
        self.output_pdf = self.output.joinpath("pdf")

        for i in [self.output, self.output_latex, self.output_pdf]:
            if not i.exists():
                i.mkdir(parents=True)

    def __repr__(self):
        cdef str src = str(os.path.relpath(self.source, self.cwd))
        cdef str out = str(os.path.relpath(self.output, self.cwd))

        return " ".join([
            f"<{self.__class__.__name__}",
            f'path="{self.cwd}"',
            f'source="{src}"',
            f'output="{out}/>"'
        ])






