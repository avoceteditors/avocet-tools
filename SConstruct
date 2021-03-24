# SConstruct Build Specification
options = ["-std=c++20", '-DVERSION="0.2"']

# Debugging
debug = ARGUMENTS.get('debug', False)
trace = ARGUMENTS.get('trace', False)

if trace:
    options.append("-DENABLE_DEBUG")
    options.append("-DENABLE_TRACE")
elif debug:
    options.append("-DENABLE_DEBUG")

# Configure Libraries
libraries = [
    "libboost_filesystem",
    "libboost_system",
]

libpaths = [
    "/usr/lib",
    "/usr/lib64"]

# Configure Includes
includes = [
    "/usr/include",
    "/usr/include/boost",
]

env = Environment(
    CXX="clang++",
    CXXFLAGS=options,
    LIBPATH=libpaths,
    LIBS=libraries,
    CPPATH=includes
)
# Build Program
env.Program(
    "bin/avocet",
    Glob("src/avocet.cpp")
)
