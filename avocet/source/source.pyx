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

# Local Imports
from avocet.source cimport LaTeXData, YaMLData, RSTData, ResourceData
# Logger Configuration
from logging import getLogger
logger = getLogger()

############################ SOURCE CLASS #############################
cdef class Source:

    def __init__(self, path):
        self.cwd = path
        self.data_latex = {}
        self.data_yaml = {}
        self.data_rst = {}
        self.data_other = {}
        self.load_paths()

    def __repr__(self):
        return "\n\t".join([
            f"<{self.__class__.__name__}>"
            "<LaTeXSources>",
                "   \n".join([""] ++ list(self.data_latex)),
            "</LaTeXSources>",
        ])

    def load_paths(self):
        for i in self.cwd.rglob("*"):
            if i.is_file():
                if i.suffix == ".tex":
                    logger.debug("LaTeX Source File")
                    self.data_latex[i] = LaTeXData(i)
                elif i.suffix == ".yml":
                    logger.debug("YaML Source File")
                    self.data_yaml[i] = YaMLData(i)
                elif i.suffix == ".rst":
                    logger.debug("reStructuredText File")
                    self.data_rst[i] = RSTData(i)
                else:
                    logger.debug(f"Unknown {i.suffix} resource file")
                    self.data_other[i] = ResourceData(i)


