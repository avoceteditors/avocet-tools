from avocet.source cimport Source, LaTeXData
from avocet.document cimport Document, LaTeXDocument
cdef inline int is_doc(LaTeXData data)
cdef inline void build(LaTeXData data, dict src, dict langs)
cdef inline LaTeXDocument make_doc(LaTeXData data)
