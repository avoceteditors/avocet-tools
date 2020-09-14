Avocet Tools
##############

Avocet Editorial Consulting provides technical writers and developers for documentation needs.  

Avocet Tools is a project aimed at developing a standard set of command-line tools to assist technical and fiction writers in common tasks and operations.  It is written in Python 3.8 and Cython.

Installation
*************

To install: 

.. code-block:: console

   $ pip3 install Cython
   $ make dev-install

Usage
******

Avocet Tools are called from the command-line through the ``avocet`` interface.

``ls``
=======

The ``ls`` operation is intended as a utility in developing functions to retrieve and categorize file lists from a given directory or set of directories.  When called, it provides the file type, path, and the recorded metadata Avocet found on a given set of files.

.. code-block:: console

   $ avocet ls test
   RSTSourceFileType: /home/kbapheus/public/avocet-tools/test/document.rst
     Name:                 document
     Parent:               test
     Last Modified (Unix): 1600039943
     Last Modified (Date): Sunday, September 13, 2020
     Size (File System):   719B
     Size (Readable):      719B
   MDSourceFileType: /home/kbapheus/public/avocet-tools/test/document.md
     Name:                 document
     Parent:               test
     Last Modified (Unix): 1600039955
     Last Modified (Date): Sunday, September 13, 2020
     Size (File System):   844B
     Size (Readable):      844B

The purpose of the command is to show the file system-level information Avocet Tools has available on source files.

``version``
============

The ``version`` operation provides generic version information on the current release of Avocet Tools:

.. code-block:: console

   $ avocet version
   Avocet - version 2020.3



