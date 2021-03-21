##############################################################################
# Copyright (c) 2020, Kenneth P. J. Dyer <kenneth@avoceteditors.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder nor the name of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
##############################################################################

# Module Imports
import pathlib
import yaml
import re

# Configure Logger
from logging import getLogger
logger = getLogger()

def load(path):
    try:
        with open(path, "r") as f:
            return yaml.load(f.read(), Loader=yaml.SafeLoader)
    except Exception as e:
        return {}

############################# DATAFILE CLASSES ############################
class DataFile:
    def __init__(self, path, config):
        self.config = config
        self.path = path
        self.paths = [path]
        self.name = path.stem
        self.valid = True
        self.mtime = self.path.stat().st_mtime
        self.mtimes = [self.mtime]
        self.document = False
        self.parent = None
        self.chapter = False
        self.title = ''

        # Perform filetype specific processing
        self.read()

    def __repr__(self):
        return f'<{self.__class__.__name__}: name="{str(self.name)}" mtime="{self.mtime} document={self.document}":/>'

    def read(self):
        pass

    def read_file(self):
        try:
            with open(self.path, "r") as f:
                return f.read()
        except Exception as e:
            logger.warn(f"Error reading file {self.path}: {e}")

    def reset_mtimes(self):
        self.mtime = max(self.mtimes)

############################## LATEX FILE ##################################
doc_pattern = re.compile("^\\\\documentclass\{book\}|^\\\\documentclass\[.*?\]\{book\}")
inc_pattern = re.compile("^\\\\INCLUDE\{(.*?)\}")
inclex_pattern = re.compile("^\\\\INCLUDELEXICON\{(.*?)\}")
newline = re.compile("\n")
chap_pattern = re.compile("^\\\\chapter\\*\{(.*?)\}", re.MULTILINE)
thechap_pattern = re.compile("^\\\\chapter\\*\{Chapter \\\\thechapter\}")

class TeXFile(DataFile):

    def read(self):
        self.text = self.read_file()
        if re.match(doc_pattern, self.text):
            self.document = True

    def process_includes(self, source, book, ):
        lines = []
        self.parent = book
        
        for line in re.split(newline, self.text):
            targets = re.findall(inc_pattern, line)
            if len(targets) > 0:
                for target in targets:
                    path = str(self.path.parent.joinpath(f"{target}.tex"))

                    subtex = source.texfiles.get(path, None)
                    if subtex is not None:

                        subtex.process_includes(source, book)
                        self.mtimes += subtex.mtimes
                        self.paths.append(path)
                        lines.append(subtex.text)
            else:
                targets = re.findall(inclex_pattern, line)
                if len(targets) > 0:
                    for target in targets:
                        base_path = self.config["lexica"].joinpath(f"{target}")
                        if base_path.exists():
                            for def_path in sorted(base_path.glob("*.tex")):
                                path = str(def_path)
                                subtex = source.texfiles.get(path, None)
                                if subtex is not None:
                                    subtex.process_includes(source, book)
                                    self.mtimes += subtex.mtimes
                                    self.paths.append(path)
                                    lines.append(subtex.text)
                else:
                    lines.append(line)

        self.text = "\n".join(lines)


############################## SOURCE CLASS #############################
class Source:

    def __init__(self, config):
        self.config = config
        self.books = []
        self.chapters = []
        self.texfiles = {} 

    def add_tex(self, path):
        texfile = TeXFile(path, self.config)
        if texfile.valid:
            self.texfiles[str(path)] = texfile
    def __repr__(self):
        return f"<{self.__class__.__name__} LaTeX: {self.texfiles}/>"

    def find_books(self):
        for name, texfile in self.texfiles.items():
            logger.debug(f"Processing {name}")
            texfile.process_includes(self, texfile)

        for name, texfile in self.texfiles.items():
            texfile.reset_mtimes()


def get_source(config):

    src = Source(config)

    # Collect LaTeX Files
    for tex in config["source"].rglob("*.tex"):
        src.add_tex(tex)

    src.find_books()

    return src

re_title = re.compile("^\\\\title\{(.*?)\}", re.MULTILINE)
def process_chapter(source, tex, outtex):

    head = ""

    for path, texfile in source.texfiles.items():
        if texfile.name == "head-chapter":
            head = texfile.text
    titles = re.findall(chap_pattern, tex.text)
    if len(titles) > 0:
        title = titles[0]

    lines = [
        "\\documentclass[letterhead,oneside]{book}",
        head,
        "\\setChapTitle{%s}" % title,
        "\\graphicspath{%s}" % str(outtex),
        "\\setCloud{%s/chapter-%s-cloud.png}" % (str(outtex), tex.path.stem),
        "\\begin{document}",
        "\\maketitle",
        tex.text,
        "\\end{document}"
    ]
    
    return "\n".join(lines)


####################### GENERATE DICTIONARIES ############################
class Lexica:
    def __init__(self):
        self.lexica = {}

    def add(self, data):
        key = data["lexicon"]
        if key in self.lexica:
            self.lexica[key].add(data)
        else:
            lex = Lexicon(key)
            lex.add(data)
            self.lexica[key] = lex

def render_gramm(text):
    return "\\dyerLangGramm{%s}" % text

def render_name(text):
    return "\\dyerLangTerm{%s}" % text

def render_def(text):
    return "\\dyerLangDefinition{%s}" % text

def render_notes(text):
    return "\\dyerLangNotes{%s}" % text

def render_phone(text):
    return "\\dyerLangPhonetic{%s}" % text

class Lexicon:
    def __init__(self, name):
        self.name = name
        self.terms = {}
        self.groups = {}

    def add(self, data):
        for entry in data.get("terms", []):
            term = entry.get("term", "__NONE__")
            name = entry.get("name", "__NONE__")
            gramm = entry.get("gramm", None)
            definition = entry.get("definition", None)
            phone = entry.get("phone", None)
            notes = entry.get("notes", None)
            init = entry.get("init", None)
            key = f"{term}--{name}"

            # Format
            if gramm is not None:
                gramm = render_gramm(gramm)
            else:
                gramm = ""
            name = render_name(name)
            if definition is not None:
                definition = render_def(definition)
            else:
                definition = ""

            if notes is not None:
                notes = render_notes(notes)
            else:
                notes = ""

            if phone is not None:
                phone = render_phone(phone)
            else:
                phone = ""


            new_entry = {
                "term": term,
                "name": name,
                "gramm": gramm,
                "phone": phone,
                "def": definition,
                "notes": notes
            }

            if init is None:
                init = term[0].lower()

            if init in self.terms:
                group = self.terms[init]
                if key in group:
                    self.terms[init][key].append(new_entry)
                else:
                    self.terms[init][key] = [new_entry]
            else:
                self.terms[init] = {key: [new_entry]}

# Get YaML
def get_yaml(src):

    lexes = []

    for yml_path in src.rglob("*.yml"):
        yml = load(yml_path)

        if "lexicon" in yml:
            lexes.append(yml)

    return lexes
def gen_lexica(config):
    lexes = get_yaml(config["source"])
    lexica = Lexica()
    for lex in lexes:
        lexica.add(lex)

    for key, lexicon in lexica.lexica.items():
        lex_path = config["lexica"].joinpath(key)
        if not lex_path.exists():
            lex_path.mkdir(parents=True)

        for group, terms in lexicon.terms.items():
            out_path = lex_path.joinpath(f"{group}.tex")
            text = ["\\dyerLangGroupLabel{%s}" % group.upper()]

            # Add Entries
            for term, defs in sorted(terms.items()):
                name = defs[0]["name"]
                if len(defs) == 1:
                    data = defs[0]
                    entry = f"%s %s %s %s" % (name, data['gramm'], data['def'], data["notes"])
                else:
                    name = "%s" % name
                    count = 0
                    entries = []
                    for data in defs:
                        count += 1
                        info = f"%s. %s %s %s" % (count, data['gramm'], data['def'], data['notes'])
                        entry.append(info)
                    entry = "; ".join(entries)
                    entry = f"{name} {entry}"

                text.append("\\dyerLangEntry{%s}" % entry)

            with open(out_path, "w") as f:
                f.write("\n\n".join(text))












