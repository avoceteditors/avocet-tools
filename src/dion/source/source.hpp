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

#ifndef DION_SOURCE_SOURCEFILE
#define DION_SOURCE_SOURCEFILE

#include"file.hpp"
class SourceFile : public File {

    public:
        // Members
        std::string raw_content, content;
        bool doc, chapter;

        // Constructor
        SourceFile(void) : File{}{}
        SourceFile(boost::filesystem::path path) : File{path}{
            TRACE("Initialize Document Types");
            this->doc = false;
            this->chapter = false;

            TRACE("Reading Content into Source Instance");
            std::ifstream is(path.string());
            if(!is.is_open()){
                ERROR("Unable to open file: " << path.string());
                this->valid = false;
            }
            this->raw_content = Glib::ustring((std::istreambuf_iterator<gchar>(is)), std::istreambuf_iterator<gchar>());
            this->content = this->raw_content;
        }
};
#endif
