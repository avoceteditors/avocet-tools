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
import lxml.etree
import sys

# Local Imports
cimport avocet.xml.stat as stat
cimport avocet.xml.common as com

# Configure Logging
from logging import getLogger
logger = getLogger(__name__)

cdef void compile(object src, object output, str default_quotes):
    """Compiles an XML file into a single cache target"""

    # Initialize Doc
    try:
        doc = lxml.etree.parse(str(src))
        doc.xinclude()

    except Exception as e:
        logger.critical(f"Unable to parse XML source: {e}")
        sys.exit(1)

    # Fetch Element
    element = doc.getroot()
    stat.set_system_data(element, src)

    # Process dion:includes
    for dinc in com.xpath(element, com.dincs):
        com.process_dincs(dinc, src)

    # Process Quotes
    com.process_quotes(element, default_quotes)
 
    # Configure Output
    out = output.joinpath(src.name)
    logger.debug(f"Output set: {str(out)}")

    with open(out, "wb") as f:
        f.write(lxml.etree.tostring(element))


   
