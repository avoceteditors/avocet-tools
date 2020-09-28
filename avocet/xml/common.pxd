"""Specifies common variables for XML processing"""

cdef inline dict ns 
    
# Date Format
cdef inline str date_format 
cdef inline str year_format 

# XML Element Reference
cdef inline str dion_include 
cdef inline str dion_lmtime 
cdef inline str dion_mtime 
cdef inline str dion_path 
cdef inline str dion_quotes
cdef inline str dion_year

# dion:include
cdef inline str dincs 

# Functions
cdef inline void process_dincs(object element, object path)
cdef inline void process_quotes(object element, str default_quotes)
cdef inline list xpath(object element, str path)
