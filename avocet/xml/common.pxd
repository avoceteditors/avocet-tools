"""Specifies common variables for XML processing"""

cdef inline dict ns 
    
# Date Format
cdef inline str date_format 
cdef inline str year_format 
cdef inline str month_format 

# XML Element Reference
cdef inline str dion_include 
cdef inline str dion_lmtime 
cdef inline str dion_mtime 
cdef inline str dion_path 
cdef inline str dion_quotes
cdef inline str dion_year
cdef inline str dion_month
cdef inline str dion_ctime_attr
cdef inline str dion_paths_root
cdef inline str book_stat_sect
cdef inline str book_stat_para
cdef inline str book_stat_text

cdef inline str book_book_all
cdef inline str book_chapter_all
cdef inline str xml_id 
# dion:include
cdef inline str dincs 
cdef inline str dion_stat_lines 
cdef inline str dion_stat_words
cdef inline str dion_stat_chars

cdef inline str dion_status 

cdef inline str book_sections
cdef inline str book_parts
cdef inline str book_local_chapters

# Functions
cdef inline void process_sections(object element)
cdef inline void process_dincs(object element, object path)
cdef inline void process_quotes(object element, str default_quotes)
cdef inline list xpath(object element, str path)
