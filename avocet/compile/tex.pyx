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
import re

# Local Imports
from avocet.source cimport Source, LaTeXData
from avocet.document cimport LaTeXDocument

# Configure Logger
from logging import getLogger
logger = getLogger()

# ReStructuredText Patterns
doc_pattern = re.compile("^\\\\documentclass\{.+?\}|^\\\\documentclass\[.*?\]\{.+?\}", re.MULTILINE)
inc_pattern = re.compile("^\\\\INCLUDE\{(.*?)\}")
inclex_pattern = re.compile("^\\\\INCLUDELEXICON\{(.*?)\}")
newline = re.compile("\n")

cdef int is_doc(LaTeXData data):
    if re.match(doc_pattern, data.content):
        return True
    else:
        return False

cdef void render_term(list entry, term):
    entry.append("\\dyerLangGramm{%s}" % term.gramm)
    entry.append("\\dyerLangDefinition{%s}" % term.definition)



cdef void build(LaTeXData data, dict src, dict langs):
    logger.debug(f"Building: {str(data.path)}")
    cdef LaTeXDocument doc

    text = []
    for line in re.split(newline, data.content):
        targets = re.findall(inc_pattern, line)
        if len(targets) > 0:
            target = targets[0]
            if "*" in target:
                for path in data.path.parent.glob(target):
                    if path.suffix == ".tex":
                        if path in src:
                            subdata = src[path]
                            build(subdata, src, langs)
                            data.mtimes = data.mtimes + subdata.mtimes

                            text.append(subdata.content)
            else:
                path = data.path.parent.joinpath(f"{target}.tex").resolve()
                if path in src:
                    subdata = src[path]
                    build(subdata, src, langs)
                    data.mtimes = data.mtimes + subdata.mtimes

                    text.append(subdata.content)
        else:
            lexica = re.findall(inclex_pattern, line)
            if len(lexica) > 0:
                for lex in lexica:
                    if lex in langs:
                        lang = langs[lex]
                        entries = []
                        for group, term_groups in sorted(lang.terms.items()):
                            entries.append("\\dyerLangGroupLabel{%s}" % group)

                            for term, term_group in sorted(term_groups.items()):
                                val = term_group[0]

                                entry = ["\\dyerLangEntry{", 
                                         "\\dyerLangTerm{%s}" % val.entry, 
                                         "\\dyerLangPron{%s}" % val.pron_latex
                                         ]

                                if len(term_group) > 1:
                                    count = 0
                                    for val in term_group:
                                        count += 1
                                        entry.append("\\dyerLangTermLabel{%s}" % count)
                                        render_term(entry, val)
                                else:
                                    render_term(entry, val)
                                entry.append("}")
                                entries.append(" ".join(entry))
                    text.append("\n".join(entries))

            else:
                text.append(line)

    data.content = "\n".join(text)

cdef LaTeXDocument make_doc(LaTeXData data):
    cdef LaTeXDocument doc = LaTeXDocument(data)



