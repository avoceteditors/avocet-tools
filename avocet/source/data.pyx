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
import yaml


##################################### SUPERCLASSES #####################################
cdef class DataFile:

    def __init__(self, path):
        self.path = path 
        self.mtime = self.get_mtime()
        self.content = None
        self.mtimes = [self.mtime]

    def get_mtime(self):
        return self.path.stat().st_mtime

    def check(self):
        return self.path.stat().mtime > self.mtime

    def __repr__(self):
        return f"<{self.__class__.__name__} path='{str(self.path)}'>"

    def read(self):
        pass

cdef class SourceData(DataFile):
    def read(self):
        with open(self.path, "r") as f:
            self.content = f.read()

cdef class ResourceData(DataFile):
    pass

cdef class LaTeXData(SourceData):
    pass

cdef class YaMLData(SourceData):

    def read(self):
        # Read Source Data
        SourceData.read(self)

        self.data = yaml.load(self.content, Loader=yaml.SafeLoader)

cdef class RSTData(SourceData):
    pass

