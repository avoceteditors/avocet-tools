Avocet Tools
##############

Avocet Editorial Consulting provides technical writers and developers for documentation needs.

Avocet Tools provides a collection of command-line utilities for fiction and technical writers working in Linux environments.  While some of these tools may work on other platforms, this is facet is accidental and remains untested.  They are primarily developed in Python 3.

Installation
**************

To install Avocet Tools, run the setup script:

.. code-block:: console

   $ python3 setup.py install

Requires `Wufilia <https://github.com/avoceteditors/wulfila>`_ and `Dion <https://github.com/avoceteditors/dion>`_.

Usage
******

The primary interface for Avocet Tools is the ``avocet`` utility.  It supports the following commands:

* Tool searches up from the current directory for a ``project.yml`` file, which it expects to provide source and output paths.

* Searches the source path for relevant source files.  Currently uses the Dion library to process LaTeX and YaML. 

* Wulfila is used to process YaML files for language specifications and lexica.

* A special ``\INCLUDE{}`` command is processed to pull documents in from other files.  This differs from the LaTeX native ``\include{}`` in that it searches from the current directory of the file.

* A special ``\INCLUDELEXICON{}`` command is processed to render a lexicon from Wulfila language specs.  This allows Wulfila to perform operations on the dictionary without requiring the writer to maintain separate LaTeX documents for presentation.

Here is an example ``project.yml``

.. code-block:: yaml

   project: Example
   source: src
   output: build

The following commands are available:

``compile``
==================

Using this command, Avocet compiles the given LaTeX documents and YaML data into PDF's.

.. code-block:: console

   $ avocet compile

Using the ``--engine`` option, you can specify the LaTeX processor you would like to run.  It defaults to ``lualatex``, but accepts ``pdlatex`` and ``xelatex``.

If you would to perform separate operations on the LaTeX document, the ``--no-latex`` option is also available.  This command disables the PDF rendering stage of the operation.  Avocet still reads source data and renders a LaTeX file in the ``build`` directory.

The ``--engine`` option is also available to select the LaTeX processor that renders the PDF.  It defaults to the ``lualatex`` command.

When the ``--all`` option is set, Avocet builds all available documents.  When it is not set, Avocet instead renders the most recent book.

