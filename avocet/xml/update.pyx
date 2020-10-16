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
import lxml.etree
import re
import sys

# Local Imports
cimport avocet.xml.common as com

# Configure Logger
from logging import getLogger
logger = getLogger(__name__)

# ReGex 
ws = re.compile("\s+")

# Process CTimes
cdef void process_ctimes(element):
    logger.debug("Processing file creation times")

    cdef str ctime
    for e in com.xpath(element, com.dion_paths_root):
        ctime = e.get(com.dion_ctime_attr)
        if ctime is None:
            path = e.get(com.dion_path)
            logger.warning(f"Unspecified dion:ctime for: {path}")

# Process Counts
cdef void process_counts(element):
    logger.debug("Processing document statistics")
    cdef int lines, words, chars 
    cdef str text

    for sect in com.xpath(element, com.book_stat_sect):
        lines = 0
        words = 0
        chars = 0
        for para in com.xpath(sect, com.book_stat_para):
            lines += 1
            for text_element in com.xpath(para, com.book_stat_text):
                text = str(text_element)
                words += len(re.split(ws, text))
                chars += len(re.sub(ws, "", text))

        sect.set(com.dion_stat_lines, str(lines))
        sect.set(com.dion_stat_words, str(words))
        sect.set(com.dion_stat_chars, str(chars))


# Process Update
cdef void process(path):

    try:
        doc = lxml.etree.parse(str(path))
        
    except Exception as e:
        logger.critical(f"Unable to read cache file: {str(path)}")
        sys.exit(1)

    element = doc.getroot()

    # Check for CTimes
    process_ctimes(element)

    # Compile Counts
    process_counts(element)


    # Overwrite Text
    doc.write(str(path), pretty_print=True)
