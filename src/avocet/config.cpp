
/************************************************************************************
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

static Config config;

// Load Langs
void load_langs(Config &config){

    // Init Variables
    std::string lang_key;
    Dion::YaMLSource yml;
    std::map<std::string, Wulfila::Language> langs;
       
    TRACE("Iterate over YaML Files");
    std::cout << "Size: " << i << std::endl;
    for (std::pair<boost::filesystem::path, Dion::YaMLSource> e : config.data_yml){
        yml = e.second;
        lang_key = yml.raw["language"].as<std::string>();
        std::cout << lang_key << "\n\n";
    }
}

// Find Project
boost::filesystem::path get_project(std::string cwdOpt){
    boost::filesystem::path yml(cwdOpt);
    yml = boost::filesystem::canonical(yml);
    boost::filesystem::path root("/");

    while (yml != root) {
        yml /= "project.yml";
        if (boost::filesystem::exists(yml)){
            return yml;
        }
        yml = yml.parent_path().parent_path();
    }
    FATAL("Unable to locate document root");

    EXIT_FAILURE;
    return yml;
}

// Create Directory if Doesn't Exist
boost::filesystem::path ensure_outdir(boost::filesystem::path path, std::string append){
    boost::filesystem::path out(path);
    if (append != "."){ 
        out /= append;
    }
    if (!boost::filesystem::exists(out)){
        TRACE("Creating Output Directory: " << out.string());
        boost::filesystem::create_directory(out);
    }
    return boost::filesystem::canonical(out);
}
boost::filesystem::path ensure_outdir(std::string path, std::string append){
    boost::filesystem::path out(path);
    return ensure_outdir(out, append);
}

// Append Source
Config append_source(Config config, boost::filesystem::path path){
    Dion::File file;
    Dion::LaTeXSource tex;
    Dion::YaMLSource yml;

    // Load Extension
    std::string ext = path.extension().string();
    TRACE("Appending " << path.string() << "by Extension: " << ext);
    if (ext == ".tex"){
        TRACE("Found LaTeX File");
        config.data_tex.insert(std::pair<boost::filesystem::path, Dion::LaTeXSource>(path, Dion::LaTeXSource(path)));
    }
    else if (ext == ".rst"){
        TRACE("Found reStructuredText File");
    }
    else if (ext == ".yml"){
        TRACE("Found YaML File");
        config.data_yml.insert(std::pair<boost::filesystem::path, Dion::YaMLSource>(path, Dion::YaMLSource(path)));
    } else {
        TRACE("Unknown File Extension (" << ext << ") on: " << path.string());
        config.data_other.insert(std::pair<boost::filesystem::path, Dion::File>(path, Dion::File(path)));
    }
    return config;
}

// Load Source Directories
Config load_source(Config config){
    for (boost::filesystem::path path : boost::filesystem::recursive_directory_iterator(config.src)){
        if (boost::filesystem::is_regular_file(path) & path.has_extension()){
            config = append_source(config, path);
        }
    }
    return config;
}

// Initialize Configuration
Config init(std::string cwdArg){
    DEBUG("Initializing Application");
    boost::filesystem::path cwd, yml, src, out, out_latex, out_pdf, out_html;

    // Locate Document Root
    TRACE("Locate Document Root");
    yml = get_project(cwdArg);
    cwd = yml.parent_path();
    DEBUG("Document Root: " << cwd.string());

    // Load Project Configuration
    TRACE("Load Config");
    YAML::Node data = YAML::LoadFile(yml.string());

    // Configure Source
    TRACE("Configure Source");
    src = boost::filesystem::path(cwd.string());
    src /= data["source"].as<std::string>();
    if (!boost::filesystem::exists(src)){
        FATAL("Non-existent Source: " << src.string());
        EXIT_FAILURE;
    }
    src = boost::filesystem::canonical(src);
    DEBUG("Source Directory: " << src.string());

    // Configure Output
    TRACE("Configure Output Directory");
    out = ensure_outdir(data["output"].as<std::string>(), ".");
    out_latex = ensure_outdir(out, "latex"); 
    out_pdf = ensure_outdir(out, "pdf");
    out_html = ensure_outdir(out, "html");
    DEBUG("Output Directory: " << out.string());

    // Initialize the Config Instance
    TRACE("Initialize Config");
    config = Config(cwd, src, out, out_latex, out_pdf, out_html);

    // Read in Source Files
    TRACE("Load Source");
    config = load_source(config);

    // Load Language
    TRACE("Loading Languages");
    load_langs(config);

    return config;
}
