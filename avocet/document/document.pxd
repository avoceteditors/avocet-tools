from avocet.source cimport Source, SourceData, LaTeXData, YaMLData
cdef class Document:
    cdef public SourceData src
    cdef public int valid
    cdef public str text
    cdef public str name
    cdef public str filename

cdef class LaTeXDocument(Document):
    cdef public str pdf_filename
