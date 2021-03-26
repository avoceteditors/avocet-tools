
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
#ifndef AVOCET_CONFIG
#define AVOCET_CONFIG
class Config {

    public:

        // Members
        boost::filesystem::path cwd;
        boost::filesystem::path src;
        boost::filesystem::path out;
        boost::filesystem::path out_latex;
        boost::filesystem::path out_pdf;
        boost::filesystem::path out_html;

        std::map<boost::filesystem::path, Dion::LaTeXSource> data_tex;
        std::map<boost::filesystem::path, Dion::YaMLSource> data_yml;
        std::map<boost::filesystem::path, Dion::File> data_other;

        // Constructors
        Config(){}
        Config(
            boost::filesystem::path cwdArg,
            boost::filesystem::path srcArg,
            boost::filesystem::path outArg,
            boost::filesystem::path outLatexArg,
            boost::filesystem::path outPDFArg,
            boost::filesystem::path outHTMLArg){
            this->cwd = cwdArg;
            this->src = srcArg;
            this->out = outArg;
            this->out_latex = outLatexArg;
            this->out_pdf = outPDFArg;
            this->out_html = outHTMLArg;
        }

};

#include"config.cpp"
#endif
