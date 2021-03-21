cdef class DataFile:
    cdef public object path
    cdef public float mtime
    cdef public str content
    cdef public list mtimes

cdef class SourceData(DataFile):
    pass

cdef class ResourceData(DataFile):
    pass

cdef class LaTeXData(SourceData):
    pass

cdef class YaMLData(SourceData):
    cdef public object data

cdef class RSTData(SourceData):
    pass
