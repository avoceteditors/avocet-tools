import datetime

cdef class FileType(object):

    def __init__(object self, object path):
        self.path = path.absolute()
        self.suffix = path.suffix
        self.base = path.stem
        self.parent = path.parent

        # Update Metadata
        self.update()

    def __repr__(object self):
            return f"{self.__class__.__name__}: {str(self.path)}"

    def __str__(object self):
        return "\n  ".join(
            [f"{self.__class__.__name__}: {str(self.path)}",
             f"Name:                 {self.base}",
             f"Parent:               {str(self.parent)}",
             f"Last Modified (Unix): {self.stat_mtime}",
             f"Last Modified (Date): {self.mtime}",
             f"Size (File System):   {self.stat_size}B",
             f"size (Readable):      {self.size}"
             ])

    def check(object self):
        return self.path.stat().st_mtime > self.mtime 

    def update(object self):

        stat = self.path.stat()

        # Set Last Modified
        self.stat_mtime = stat.st_mtime
        date = datetime.datetime.fromtimestamp(self.stat_mtime)
        self.mtime = date.strftime("%A, %B %d, %Y")
        self.year = date.strftime("%Y")

        # File Size
        self.stat_size = stat.st_size

        cdef float size
        cdef str unit
        if self.stat_size > 1000000:
            size = 1000000 / self.stat_size
            unit = "MB"
        elif self.stat_size > 1000:
            size = 1000 / self.stat_size
            unit = "KB"
        else:
            size = self.stat_size
            unit = "B"

        self.size = f"{int(size)}{unit}"
