from avocet.source cimport Source

cdef class Config:
    cdef public object cwd
    cdef public object cache
    cdef public object cache_source

    cdef public object source
    cdef public object output
    cdef public object output_latex
    cdef public object output_pdf

    cdef public Source src
    
