
cdef inline void set_system_data(object element, object path)
cdef inline void report_stats(path, int verbose)

cdef class Book:
    cdef object element
    cdef str idref
    cdef list chapter_stats
    cdef int current_wc
    cdef int projected_wc
    cdef int part_count
    cdef int projected_chapter_count
    cdef int avg_chapter_count
    cdef int avg_chapter_wc


