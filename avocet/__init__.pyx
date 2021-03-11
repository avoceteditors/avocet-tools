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
import pathlib

from pkg_resources import get_distribution

# Local Imports
from avocet import compile
cimport avocet.config

############################ VERSION REPORT ##################################

cdef str prog = "avocet"
cdef str byline = "Development Utilities for Fiction Writers, Technical Writers, and Conlangers"
cdef str author = "Kenneth P. J. Dyer <kenneth@avoceteditors.com>"
cdef str comp = "Avocet Editorial Consulting"
cdef str version_avocet = get_distribution("avocet").version
cdef str version_dion = get_distribution("dion").version

cdef void report_version(object args):
    """Reports version and developer information to the command-line"""

    # Instantiate Variable
    cdef list content
    cdef str name

    # Build Verbose Output
    if args.verbose:

        content = [
            f"{prog.capitalize()} - {byline}", 
           author, 
            comp, 
            "Versions:",
            f"- Avocet Tools           v.{version_avocet}", 
            f"- Dion Text Processor    v.{version_dion}",
            f"- Wulfila Language Tools v.None",
            "\n"]


    # Build Non-verbose Output
    else:
        content = [f"{prog} - version {version_avocet}"]
    print("\n  ".join(content))

cpdef void main():
    """Main Avocet Tools Process"""

    ############################# ARGUMENT PARSER ##########################
    # Initialize Parser
    parser = argparse.ArgumentParser(
        prog=prog)
    parser.set_defaults(func=report_version)

    ############## OPTIONS #######################
    opts = parser.add_argument_group("Options")

    # All Pages
    opts.add_argument(
        "-a", "--all", action="store_true",
        help="build all documents, chapters included")

    opts.add_argument(
        "-C", "--working-dir", default=".",
        help="Forces certain operations")

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
        "-o", "--output", default="./build",
        help="Specifies the output directory")

    opts.add_argument("--chapters", action="store_true")

    opts.add_argument("-U", "--no-latex", action="store_true")

    # Verbosity
    opts.add_argument(
        "-v", "--verbose", action="store_true",
        help="Enables verbosity in logging messages")

    ################# COMMANDS #####################
    cmds = parser.add_subparsers(title="Commands", help="Command you want to execute")

    # Config Command
    cmd_config = cmds.add_parser(
        "config",
        help="Finds the configuration file and reports on current data.")
    cmd_config.set_defaults(func=avocet.config.run)

    # Compile LaTeX
    cmd_compile = cmds.add_parser(
        "compile",
        help="Compiles LaTeX documents into PDF")
    cmd_compile.set_defaults(func=compile.run)

    cmd_compile.add_argument(
        "source", nargs="?",
        default="./project.yml",
        help="Source YaML to use in building the project")

    # Version Command
    cmd_ver = cmds.add_parser(
        "version",
        help="Reports version and developer information.")

    args = parser.parse_args()

    ################## LOGGING CONFIGURATION ###########
    cdef str log_format = "[%(levelname)s]: %(message)s"

    if args.debug:
        log_level = logging.DEBUG
    elif args.verbose:
        log_level = logging.INFO
    else:
        log_level = logging.WARN

    logging.basicConfig(format=log_format, level=log_level)

    # Configure Pathlib
    args.working_dir = pathlib.Path(args.working_dir).resolve()

    # Run Application
    args.func(args)




