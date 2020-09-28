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

# Local Improts
cimport avocet.xml.stat as stat

# Configure Logger
from logging import getLogger
logger = getLogger(__name__)

# Configure Variables
cdef dict ns = {
    "book": "http://docbook.org/ns/docbook",
    "xi": "http://www.w3.org/2001/XInclude",
    "xsl": "http://www.w3.org/1999/XSL/Transform",
    "xlink": "http://www.w3.org/1999/xlink",
    "dion": "http://avoceteditors.com/xml/dion",
    "py": "http://genshi.edgewall.org",
    "xml": "http://www.w3.org/XML/1998/namespace"
}

# Date Format
cdef str date_format = "%A, %B %d, %Y"
cdef str year_format = "%Y"

# XML Element Reference
cdef str book_quote = "{%s}quote" % ns['book']
cdef str dion_include = "{%s}include" % ns['dion']
cdef str dion_lmtime = "{%s}lmtime" % ns['dion']
cdef str dion_mtime = "{%s}mtime" % ns['dion']
cdef str dion_path = "{%s}path" % ns['dion']
cdef str dion_year = "{%s}year" % ns['dion']

# dion:include
cdef str book_quotes = "//book:quote" 
cdef str dincs = "//dion:include"


cdef list xpath(object element, str path):
    """Run XPath and return findings"""
    return element.xpath(path, namespaces=ns)


cdef void process_dincs(object element, object path):
    """Process dion:includes and add contents to element"""
    pattern = element.get("src")

    # Find Contents
    for i in path.parent.glob(pattern):

        try:
            doc = lxml.etree.parse(str(i))
            doc.xinclude()

            # Fetch Element
            root = doc.getroot()
            stat.set_system_data(root, i)

            # Recurse
            for dinc in xpath(root, dincs):
                process_dincs(dinc, i)

            element.addprevious(root)

        except Exception as e:
            logger.warn(f"Unable to process XML file {str(i)} from dion:include: {e}")

cdef void process_quotes(object element, str default_quotes):
    """Sets the default quotation attribute"""

    for q in xpath(element, book_quotes):
        q.set("type", default_quotes)


        
    
