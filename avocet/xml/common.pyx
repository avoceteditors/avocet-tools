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
cdef str month_format = "%B"

# XML Element Reference
cdef str book_quote = "{%s}quote" % ns['book']
cdef str dion_include = "{%s}include" % ns['dion']
cdef str dion_lmtime = "{%s}lmtime" % ns['dion']
cdef str dion_mtime = "{%s}mtime" % ns['dion']
cdef str dion_path = "{%s}path" % ns['dion']
cdef str dion_type = "{%s}type" % ns['dion']
cdef str dion_year = "{%s}year" % ns['dion']
cdef str dion_month = "{%s}month" % ns['dion']
cdef str xml_id = "{%s}id" % ns['xml']

# dion:include
cdef str book_quotes = "//book:quote" 
cdef str dincs = "//dion:include"
cdef str dion_paths = ".//*[@dion:path]"
cdef str dion_paths_root = "//*[@dion:path]"
cdef str dion_path_ancestor = "ancestor::*[@dion:path]"

cdef str book_book_all = "//book:book"
cdef str book_chapter_all = "//book:chapter|//book:article"

cdef str book_parts = "//book:part"
cdef str book_local_chapters = ".//book:chapter"

cdef str book_sections = "./book:section"

cdef str book_allsects = ".//book:part|.//book:chapter|.//book:section"

cdef str book_stat_sect = "//book:book|//book:chapter|//book:article"
cdef str book_stat_para = ".//book:para"
cdef str book_stat_text = ".//text()"

cdef str dion_stat_lines = "{%s}lines" % ns['dion']
cdef str dion_stat_words = "{%s}words" % ns['dion']
cdef str dion_stat_chars = "{%s}chars" % ns['dion']

cdef str dion_ctime_attr = "{%s}ctime" % ns['dion']
cdef str dion_status = "{%s}status" % ns['dion']

cdef list xpath(object element, str path):
    """Run XPath and return findings"""
    return element.xpath(path, namespaces=ns)

cdef list find_theme_deps(object theme_path):

    cdef list files = [] 
    cdef list sub_files

    for xsl in theme_path.glob("*.xsl"):
        name = str(xsl.stem).upper()
        sub_files = [str(xsl)]

        for i in xsl.rglob("*.xsl"):
            sub_files.append(str(i))


        files.append((name, sub_files))

    return files

cdef list find_dincs(object element):

    cdef list dincs = []

    for i in xpath(element, dion_paths):
        dincs.append(element.get(dion_path))

    return dincs

cdef str find_dpath(object element):
    cdef str path = element.get(dion_path)

    if path is None:
        for i in xpath(element, dion_path_ancestor):
            return i.get(dion_path)
    else:
        return path

cdef list find_targets(object root, target):

    cdef list books = []
    cdef list deps = []
    cdef str dpath
    cdef str xmlid

    for book in xpath(root, target):
        dpath = find_dpath(book)
        deps = find_dincs(book)
        xmlid = book.get(xml_id)
        books.append((xmlid, dpath, deps))

    return books

cdef list find_books(object root):
    return find_targets(root, book_book_all)

cdef list find_chapters(object root):
    return find_targets(root, book_chapter_all)


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
            dinc = None
            for dinc in xpath(root, dincs):
                process_dincs(dinc, i)

            element.addprevious(root)
            if dinc is not None:
                del dinc

        except Exception as e:
            logger.warn(f"Unable to process XML file {str(i)} from dion:include: {e}")

cdef void process_sections(object element):
    """Process sections to set defaults"""
    cdef str book_type

    for book in xpath(element, book_book_all):

        book_type = book.get(dion_type)

        if book_type is None:
            book_type = "novel-chapters"

        for section in xpath(book, book_allsects):
            section.set(dion_type, book_type)

        

cdef void process_quotes(object element, str default_quotes):
    """Sets the default quotation attribute"""

    for q in xpath(element, book_quotes):
        q.set("type", default_quotes)


