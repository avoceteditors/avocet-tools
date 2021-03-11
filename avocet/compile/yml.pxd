cdef class Term:
    cdef public str entry
    cdef public str group
    cdef public str name
    cdef public int valid
    cdef public list pron
    cdef public str pron_latex
    cdef public str definition
    cdef public str gramm

cdef class Language:
    cdef public str name
    cdef public list vowels
    cdef public list consonants
    cdef public dict terms
    

cdef inline void load(str key, dict data, dict register)
