# Module Imports
import subprocess
# SConstruct Build Specification
options = ["-std=c++17"]
# Debugging
debug = ARGUMENTS.get('debug', False)
trace = ARGUMENTS.get('trace', False)

defines = []
if trace:
    defines.append("ENABLE_DEBUG")
    defines.append("ENABLE_TRACE")
elif debug:
    defines.append("ENABLE_DEBUG")

# Configure Libraries
libraries = [
    "libboost_filesystem",
    "libboost_system",
    "libyaml-cpp",
    "libglibmm-2.4",
    "glibmm-2.4",
    "gobject-2.0",
    "glib-2.0",
    "sigc-2.0"
]

libpaths = [
    "/usr/lib",
    "/usr/lib64",
    "/usr/lib/x86_64-linux-gnu"
]

# Configure Includes
includes = [
    "/usr/include",
    "/usr/include/boost",
    "/usr/include/yaml-cpp",
    "/usr/include/glibmm-2.4",
    "/usr/lib/x86_64-linux-gnu/glibmm-2.4/include",
    "/usr/include/glib-2.0",
    "/usr/lib/x86_64-linux-gnu/glib-2.0/include",
    "/usr/include/sigc++-2.0",
    "/usr/lib/x86_64-linux-gnu/sigc++-2.0/include"


]

options = list(set(options))

env = Environment(
    CXX="g++",
    CXXFLAGS=options,
    CPPDEFINES=defines,
    LIBPATH=libpaths,
    LIBS=libraries,
    CPPATH=includes
)

# Build Program
env.Program(
    "bin/avocet",
    Glob("src/avocet.cpp")
)
