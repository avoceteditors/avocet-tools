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
import datetime

####################### FILETYPE CONFIGURATION ##################################
cdef class FileType(object):

    def __init__(object self, object path):
        self.path = path.absolute()
        self.suffix = path.suffix
        self.base = path.stem
        self.parent = path.parent

        # Update Metadata
        self.update()

    def __repr__(object self):
            return f"{self.__class__.__name__}: {str(self.path)}"

    def __str__(object self):
        return "\n  ".join(
            [f"{self.__class__.__name__}: {str(self.path)}",
             f"Name:                 {self.base}",
             f"Parent:               {str(self.parent)}",
             f"Last Modified (Unix): {self.stat_mtime}",
             f"Last Modified (Date): {self.mtime}",
             f"Size (File System):   {self.stat_size}B",
             f"Size (Readable):      {self.size}"
             ])

    def check(object self):
        return self.path.stat().st_mtime > self.mtime 

    def update(object self):

        stat = self.path.stat()

        # Set Last Modified
        self.stat_mtime = stat.st_mtime
        date = datetime.datetime.fromtimestamp(self.stat_mtime)
        self.mtime = date.strftime("%A, %B %d, %Y")
        self.year = date.strftime("%Y")

        # File Size
        self.stat_size = stat.st_size

        cdef float size
        cdef str unit
        if self.stat_size > 1000000:
            size = 1000000 / self.stat_size
            unit = "MB"
        elif self.stat_size > 1000:
            size = 1000 / self.stat_size
            unit = "KB"
        else:
            size = self.stat_size
            unit = "B"

        self.size = f"{int(size)}{unit}"
