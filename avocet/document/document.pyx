from avocet.source cimport Source, SourceData, LaTeXData, YaMLData

cdef class Document:

    def __init__(self, SourceData src):
        self.src = src
        self.valid = True
        self.text = src.content
        self.name = src.path.stem
        self.filename = src.path.name

        self.prepare()

    def prepare(self):
        pass

    def __repr__(self):
        return " ".join([
            f"<{self.__class__.__name__}",
            f'name="{self.name}"',
            "/>"
        ])


cdef class LaTeXDocument(Document):

    def prepare(self):
        self.pdf_filename = f"{self.name}.pdf"
