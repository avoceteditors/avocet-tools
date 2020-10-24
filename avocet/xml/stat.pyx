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
import lxml.etree
import numpy
import sys

# Local Imports
cimport avocet.xml.common as com

# Configure Logger
from logging import getLogger
logger = getLogger(__name__)

cdef class Book:

    def __init__(self, element):
        self.element = element
        self.idref = element.get(com.xml_id)

        titles = com.xpath(self.element, "book:title|book:info/book:title")
        if len(titles) > 0:
            self.idref = titles[0].text
        self.chapter_stats = []


    def gather_stats(self):
        cdef str status
        cdef int sections, lines, words, chars
        cdef list chapter_counts = []

        self.current_wc = int(self.element.get(com.dion_stat_words))

        for chapter in com.xpath(self.element, com.book_local_chapters):
            status = chapter.get(com.dion_status)
            sections = len(com.xpath(self.element, com.book_sections))
            lines = int(self.element.get(com.dion_stat_lines))
            words = int(self.element.get(com.dion_stat_words))
            chars = int(self.element.get(com.dion_stat_chars))

            self.chapter_stats.append((status, sections, lines, words, chars))

        cdef list parts = com.xpath(self.element, com.book_parts)
        cdef int count
        for part in parts:

            count = len(com.xpath(part, com.book_local_chapters))
            if part.get(com.dion_status) not in ["outline"] and count > 0:
                chapter_counts.append(count)

        self.part_count = len(parts)
        self.avg_chapter_count = numpy.mean(chapter_counts)

        chapter_counts = []

        for (status, sections, lines, words, chars) in self.chapter_stats:

            if status in ["outline", "draft"]:
                chapter_counts.append(5000)
            else:
                chapter_counts.append(words)

        self.avg_chapter_wc = numpy.mean(chapter_counts)

        self.projected_chapter_count = self.part_count * self.avg_chapter_count
        self.projected_wc = self.projected_chapter_count * self.avg_chapter_wc

    def add_leadspace(self, str text, int lead):
        cdef int text_len = len(text)
        cdef str lead_space
        if lead > text_len:
            lead = lead - text_len
            lead_space = " " * lead
            return lead_space + text
        else:
            return text

    def report(self, int verbose):

        cdef str projected_wc = f"{'{:,}'.format(self.projected_wc)}"
        cdef str current_wc = f"{'{:,}'.format(self.current_wc)}",
        cdef str progress = f"{'{:,}'.format(round((self.current_wc / self.projected_wc) * 100, 2))}%"
        cdef str avg_chap_wc = f"{'{:,}'.format(self.avg_chapter_wc)}",
        cdef str projected_cc = f"{'{:,}'.format(self.projected_chapter_count)}",

        cdef int lead = 0

        for i in [projected_wc, current_wc, progress, avg_chap_wc]:
            if lead < len(i):
                lead = len(i)

        projected_wc = self.add_leadspace(projected_wc, lead)
        current_wc = self.add_leadspace(current_wc, lead)
        progress = self.add_leadspace(progress, lead)
        avg_chap_wc = self.add_leadspace(avg_chap_wc, lead)
        projected_cc = self.add_leadspace(projected_cc, lead)

        if verbose:
            contents = [
                f"Book: {self.idref}",
                f"Average Chapter Word Count: {avg_chap_wc}",
                f"Projected Chapter Count:    {projected_cc}",
                f"Projected Word Count:       {projected_wc}",
                f"Current Word Count:         {current_wc}",
                f"Current Progress:           {progress}"
            ]
        else:
            contents = [
                f"Book: {self.idref}",
                f"Projected Word Count: {projected_wc}",
                f"Current Word Count:   {current_wc}",
                f"Current Progress:     {progress}"
            ]
        print("\n  ".join(contents))

            
    

cdef void set_system_data(object element, object path):

    # Initialize Metadata
    cdef list metadata = [(com.dion_path, str(path.absolute()))]

    # Collect Stats
    stats = path.stat()

    ############## Last Modified ################# 
    cdef int mtime = stats.st_mtime
    metadata.append((com.dion_mtime, str(mtime)))

    # Logical Mtime 
    cdef str lmtime = datetime.datetime.fromtimestamp(mtime).strftime(com.date_format)
    metadata.append((com.dion_lmtime, lmtime))

    # Logical Year
    cdef str ymtime = datetime.datetime.fromtimestamp(mtime).strftime(com.year_format)
    metadata.append((com.dion_year, ymtime))

    cdef str mmtime = datetime.datetime.fromtimestamp(mtime).strftime(com.month_format)
    metadata.append((com.dion_month, mmtime))

    for (attr, value) in metadata:
        element.set(attr, value)


cdef void report_stats(path, int verbose):
    """Reports statistical information on books in document cache"""

    cdef str book_idref
    cdef Book book

   
    logger.debug("Reading updated cache for data")
    try:
        doc = lxml.etree.parse(str(path))
        element = doc.getroot()
    except Exception as e:
        logger.critical(f"Unable to parse cache file ({str(path)}): {e}")
        sys.exit(1)

    for book_element in com.xpath(element, com.book_book_all):
        book = Book(book_element)

        book.gather_stats()
        book.report(verbose)



