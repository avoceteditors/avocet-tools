

cdef class FileType(object):
    cdef public object path
    cdef public str suffix
    cdef public str base
    cdef public object parent
    cdef public int stat_mtime
    cdef public str mtime
    cdef public str year
    cdef public int stat_size
    cdef public str size

cdef class SourceFileType(FileType):
    pass

cdef class RSTSourceFileType(FileType):
    pass

cdef class MDSourceFileType(FileType):
    pass

cdef class XMLSourceFileType(FileType):
    pass

cdef class JSONSourceFileType(FileType):
    pass

cdef class ResourceFileType(FileType):
    pass

cdef class ImageResourceFileType(ResourceFileType):
    pass

cdef class OtherResourceFileType(ResourceFileType):
    pass
