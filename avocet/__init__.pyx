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
import argparse
import logging
import coloredlogs
from pkg_resources import get_distribution

# Local Imports
from avocet.utils cimport ls
from avocet.utils cimport parse
from avocet.utils cimport compile

#################### APPLICATION METADATA ######################
cdef str prog = "Avocet"
cdef str byline = "Development Utilities for Writers"
cdef str author = "Kenneth P. J. Dyer <kenneth@avoceteditors.com>"
cdef str comp = "Avocet Editorial Consulting"
cdef str version = get_distribution("avocet").version

cdef void report_version(args):
    cdef list content
    if args.verbose:
        content = [f"{prog} - {byline}", author, comp, f"Version {version}", "\n"]
    else:
        content = [f"{prog} - version {version}"]
    print("\n  ".join(content))

##################### MAIN PROCESS ####################
cpdef void main():
    """Main process used by Avocet when called from the command-line"""

    ################ PARSE CLI ARGUMENTS ##########################
    parser = argparse.ArgumentParser(
        prog="avocet")
    parser.set_defaults(func=report_version)

    ############# OPTIONS GROUP ###############
    opts = parser.add_argument_group("Options")

    # Working Directory
    opts.add_argument(
        "-C", "--working-dir", default=".",
        help="Sets the working directory")

    # Force
    opts.add_argument(
        "-f", "--force", action="store_true",
        help="Forces certain operations")

    # Debug
    opts.add_argument(
        "-D", "--debug", action="store_true",
        help="Enables debugging information in logging messages")

    # Output
    opts.add_argument(
        "-o", "--output", default="build",
        help="Specifies the output directory")

    # Verbosity
    opts.add_argument(
        "-v", "--verbose", action="store_true",
        help="Enables verbosity in logging messages")

    ################# COMMANDS #######################
    cmds = parser.add_subparsers(title="Commands", help="Command you want to execute")

    # Compile XML
    cmd_compile = cmds.add_parser(
        "compile",
        help="Compiles source files into single XML file")
    cmd_compile.set_defaults(func=compile.run)

    cmd_compile.add_argument(
        "-Q", "--quotes", choices=["single", "double", "emdash", "none"], default="double",
        help="Configures default quotation marks to use in text")
    cmd_compile.add_argument(
        "source",
        help="Specifies the source file to compile")

                             

    # Show Files 
    cmd_ls = cmds.add_parser(
        "ls",
        help="Finds relevant files in given path tree, reports file system-level metadata")
    cmd_ls.set_defaults(func=ls.run)

    cmd_ls.add_argument("source", nargs="*", help="Specifies files to read")

    # Parse Command
    cmd_parse = cmds.add_parser(
        "parse",
        help="Parse the given files into data objects")
    cmd_parse.set_defaults(func=parse.run)
    cmd_parse.add_argument("source", nargs="*", help="Specifies files to read")

    # Version Command
    cmd_ver = cmds.add_parser(
        "version",
        help="Reports version and developer information.")


    ############## PARSE ARGUMENTS ####################
    args = parser.parse_args()

    if args.debug:
        log_level = logging.DEBUG
    elif args.verbose:
        log_level = logging.INFO
    else:
        log_level = logging.WARN

    coloredlogs.install(level=log_level)

    ############### ENVIRONMENT ###########################
    #cdef avocet.utils.env.Environment env = avocet.utils.env.Environment(args.working_dir)
    #env.configure(args.force)

    # Call
    args.func(args)


