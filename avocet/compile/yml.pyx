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

# Configure Logger
from logging import getLogger
logger = getLogger()

syllable = re.compile("\\.")
letter = re.compile("\\|")

letter_latex_data = {
    "e*": "\\textepsilon",
    "opo": "\\textopeno",
    "ae": "\\ae",
    "b^h": "b\\textsuperscript{\\texthth}",
    "b^w": "b\\textsuperscript{w}",
    "p^h": "p\\textsuperscript{h}",
    "p^w": "p\\textsuperscript{w}",
    "d^h": "d\\textsuperscript{h}",
    "d^w": "d\\textsuperscript{w}",
    "t^h": "t\\textsuperscript{h}",
    "t^w": "t\\textsuperscript{w}",
    "gw":  "\\textscg",
    "dh": "\\dh",
    "th": "\\th",
    "zh": "\\textyogh",
    "sh": "\\textesh",
    "gh": "\\textramshorns",
    "l": "\\textscl",
    "y": "\\textlambda",
    "r,": "\\textsubstring{r}"
}

cdef str format_letter(str letter):
    return "%s{}" % letter_latex_data.get(letter, "%s" % letter)

cdef class Term:
    def __init__(self, data):
        cdef str pron
        cdef list lpron = []
        self.name = data.get("term", None)
        self.entry = data.get("entry", None)
        if self.entry is None or self.name is None:
            self.valid = False
        else:
            self.group = data.get("group", self.entry[0])
            self.pron =[]
            pron = data.get("pron", self.entry)
            self.pron_syl(pron)
            for i in self.pron:
                lpron.append(format_letter(i))
            self.pron_latex = "".join(lpron)
            self.gramm = data.get("gramm", "")
            self.definition = data.get("definition", "")
            self.valid = True

    def pron_syl(self, str text):
        cdef list syls = re.split(syllable,text)
        syl_latex = []
        if len(syls) > 1:
            for syl in syls:
                syls_latex = []
                self.pron_lett(syl, syls_latex)
                syl_latex.append("".join(syls_latex))

        else:
            self.pron_lett(syls[0], syl_latex)
            syl_latex = ["".join(syl_latex)]
        self.pron.append(".".join(syl_latex))

    def pron_lett(self, str text, list syllable):
        cdef list phs = re.split(letter, text)
        for ph in phs:
            syllable.append(format_letter(ph))

    def __repr__(self):
        return " ".join([
            f"<{self.__class__.__name__}",
            f'entry="{self.entry}"',
            f'pron="{self.pron_latex}"',
            f'gram="{self.gramm}"/>'
        ])


cdef class Language:

    def __init__(self, str key):
        self.name = key
        self.vowels = []
        self.consonants = []
        self.terms = {} 

    def __repr__(self):
        return " ".join([
            f"<{self.__class__.__name__}",
            f'name="{self.name}"',
            f'vowels={self.vowels}',
            f'consonants={self.consonants}',
            f'terms={self.terms}'
            "/>"
        ])

    def add_letters(self, vowels, consonants):
        if vowels != [""]:
            self.vowels += vowels
        if consonants != [""]:
            self.consonants += consonants

    def add_terms(self, list terms):
        cdef dict entry 
        cdef Term term
        for entry in terms:
            term = Term(entry)
            if term.valid:
                if term.group in self.terms:

                    if term.name in self.terms[term.group]:
                        self.terms[term.name].append(term)
                    else:
                        self.terms[term.group][term.name] = [term]
                else:
                    self.terms[term.group] = {term.name: [term]}

pipesplit = re.compile("\\|")

cdef list find_letters(str letstr):
    return re.split(pipesplit, letstr)

cdef void load(str key, dict data, dict register):
    logger.debug(f"Updating {key} Language")

    # Initialize Variables
    cdef Language lang
    cdef list vowels
    cdef list consonants

    # Instantiate Language
    if key in register:
        lang = register[key]
    else:
        lang = Language(key)
        register[key] = lang

    # Extract Data
    for key, element in data.items():
        if key == "phonology":
            vowels = find_letters(element.get("vowels", ""))
            consonants = find_letters(element.get("consonants", ""))
            lang.add_letters(vowels, consonants)
        elif key == "terms":
            lang.add_terms(element)

