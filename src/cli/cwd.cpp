/************************************************************************************
 * cwd.cpp - Functions for finding the current working directory
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

#ifndef AVOCET_CLI_CWD
#define AVOCET_CLI_CWD

// System Includes
#include<boost/filesystem.hpp>

// Local Include
#include"../log.hpp"

// Returns the current working directory as defined by CLI arg
boost::filesystem::path get_cwd(std::string pathArg){
    DEBUG("Finding working directory");

    // Extract Value
    TRACE("Initialize Boost::Filesystem Path");
    boost::filesystem::path cwd(pathArg);

    // Check Exists
    if (boost::filesystem::exists(cwd)){

        TRACE("Make cwd a canonical path");
        cwd = boost::filesystem::canonical(cwd);

        if (boost::filesystem::is_directory(cwd)){
            return cwd;
        }
        else {
            FATAL("Working directory is a file: " << cwd.string());
            EXIT_FAILURE;
        }
    }
    else {
        FATAL("Working directory does not exist: " << cwd.string());
        EXIT_FAILURE;
    }
    return cwd;
}

// Find project.yml path
boost::filesystem::path get_project(boost::filesystem::path p){
    TRACE("Path Argument: " << p.string());
    boost::filesystem::path root("/");
    while (root != p){
        TRACE("Checking Directory for project.yml: " << p.string());
        p /= "project.yml";
        if (boost::filesystem::is_regular_file(p)){
            return p;
        }
        p = p.parent_path().parent_path();
    } 
    FATAL("Unable to locate project.yml");
    EXIT_FAILURE;
    return p;
}
#endif
