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

# Logger Configuration
from logging import getLogger
logger = getLogger()
################### VOWEL QUADRILATERAL #########################
class VowelChart:
    """Generates a vowel quadrilateral in LaTeX"""

    def __init__(self):
        self.vquad = [
            "\\begin{center}",
            "\\begin{tikzpicture}[scale=3]",
            "\\large"
            """
            \\tikzset{
                vowel/.style={fill=white,anchor=mid,text depth=0ex, text height=1ex},
                dot/.style={circle,fill=black,minimum size=0.4ex,inner sep=0pt,outer sep=-1pt},}
            """,
            "\\coordinate (hf) at (0,2);", # High Front 
            "\\coordinate (hb) at (2,2);", # High Back 
            "\\coordinate (lf) at (1,0);", # Low Front 
            "\\coordinate (lb) at (2,0);", # Low Back
            "\\draw (\\V(0,0)) -- (\\V(0,2));",
            "\\draw (\\V(1,0)) -- (\\V(1,2));",
            "\\draw (\\V(2,0)) -- (\\V(2,2));",
            "\\draw (\\V(3,0)) -- (\\V(3,2));"]

        self.registry = []

    def add(self, vowel):
        self.registry.append(vowel)

    def generate(self):
        registry = list(set(self.registry))

################### VOWEL REGISTRY #########################
def process_vowels(vowels):
    # Vowel Chart
    pass







################### BUILD LANGUAGE DATA #########################
def run(config, lang):

    # Find Name and Title
    name = lang.get("lang", "UNNAMED")
    title = lang.get("title", name)
    logger.info(f"Building Language: {title}")

    # Build Vowel Registry
    vowels = lang.get("vowels", "").split("|")

    process_vowels(vowels)
