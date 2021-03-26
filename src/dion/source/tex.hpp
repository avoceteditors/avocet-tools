/************************************************************************************
 *
 ************************************************************************************
 * Copyright (c) 2021, Kenneth P. J. Dyer <kenneth@avoceteditors.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the copyright holder nor the name of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 ************************************************************************************/

#ifndef DION_SOURCE_LATEXFILE
#define DION_SOURCE_LATEXFILE

#include"source.hpp"

class LaTeXSource : public SourceFile {

    public:

        // Members
        bool contains_include;
        bool contains_lexicon_include;

        // Constructors
        LaTeXSource(void) : SourceFile{}{}
        LaTeXSource(boost::filesystem::path path) : SourceFile{path}{

            // Init Members 
            TRACE("Initialize include status");
            this->contains_include = false;
            this->contains_lexicon_include = false;

            TRACE("Preparing Regex for File Scan");
            std::sregex_token_iterator iter(this->content.begin(), this->content.end(), re_newline, -1);
            std::sregex_token_iterator end;

            std::string line;
            while (iter != end){
                line = *iter;
                if (std::regex_search(line, re_document)){
                    this->doc = true;
                } 

                else if (std::regex_search(line, re_chapter)){
                    this->chapter = true;
                }
                
                // Increment
                ++iter;
            }
        }
};
#endif
