/************************************************************************************
 * avocet.cpp -
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

// System Includes
#include<iostream>
#include<tclap/CmdLine.h>
#include<boost/filesystem.hpp>

// Local Includes
#include"log.hpp"
#include"cli.hpp"


int main(int argc, char** argv){
    INFO("Starting Avocet");

    try {

        DEBUG("Parsing command-line options and arguments");

        // Command Line Parser
        TRACE("Initialize Tclap");
        TCLAP::CmdLine cmd("Avocet build tool", ' ', "0.2");
        TRACE("Done");

        // Options
        TRACE("Set current working directory string");
        TCLAP::ValueArg<std::string> cwdOpt("C", "cwd", "Sets the current working directory", false, ".", "stringpath");
        cmd.add(cwdOpt);
        
        // Commands

        // Parse
        TRACE("Parse tclap options");
        cmd.parse(argc, argv);
        TRACE("Done");

        // Extract Values
        boost::filesystem::path cwd = get_cwd(cwdOpt.getValue());
        boost::filesystem::path project = get_project(cwd);


    }

    // Exceptions
    catch(TCLAP::ArgException &e){
        FATAL("Invalid Command-line argument: " 
                << e.error() 
                << " for argument "
                << e.argId());
        EXIT_FAILURE;
    }

    TRACE("Exit Success");
    EXIT_SUCCESS;
}
