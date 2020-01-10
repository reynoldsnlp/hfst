*******************
Package description
*******************

Package ``hfst_dev`` contains a development version of Python bindings for
`HFST <https://hfst.github.io>`_ (Helsinki Finite-State Technology) C++ library.
HFST toolkit is intended for processing natural language morphologies.
The toolkit is demonstrated by wide-coverage implementations of a number of languages
of varying morphological complexity.

Requirements
############

We offer binary wheels for Linux and Mac OS X (and experimentally for Windows).

Wheels for Linux are compiled with a 64-bit docker image (quay.io/pypa/manylinux1_x86_64)
for python versions 3.5, 3.6 and 3.7.

Wheels for Mac are compiled as universal binaries for python versions 3.5, 3.6 and 3.7.
OS X must be 10.7 or higher.

Wheels for Windows are experimental. They are 32-bit and also require a 32-bit
python to work correctly. They are available for python versions 3.5 and 3.6;
earlier versions would need an older compiler that does not support C++11 features.
Wheels for version 3.7. may be added to future releases.

Compiling hfst_dev from source requires at least C++ compiler (tested with gcc 5.4.0),
readline and getline libraries and setuptools package for python
(tested with version 28.8.0). Swig is no longer needed as pre-generated files are
included in source distribution.

Installation via PyPI
#####################

We recommend using ``pip`` tool for installation.
Before installation, see that dependencies given under heading 'Requirements' are met.

For python version 3, the ``pip`` tool is usually named ``pip3``, plain ``pip`` being used
for python version 2. Basic installation is done with:

``pip3 install [--upgrade] hfst_dev``

Starting from python 3.4.0, pip is included by default
and can be called via python with option ``-m pip``:

``python3 -m pip install [--upgrade] hfst_dev``

The commands above are run in a shell/terminal/command prompt, but they can
also be run on python command line or via a graphical user interface
(e.g. IDLE) with ``pip.main`` that takes arguments in a list:

| ``import pip``
| ``pip.main(['install','--upgrade','hfst_dev'])``

The option ``--upgrade`` makes sure that the newest version of hfst will be installed
replacing any earlier versions installed. The option ``--verbose``
will show what happens during the installation process. This can be useful when compiling from source.

Documentation
#############

See wiki-based `package documentation <https://github.com/hfst/python-hfst-4.0/wiki>`_
on our Github pages. In python, you can also use ``dir`` and ``help``
commands, e.g.:

``dir(hfst_dev)``

``help(hfst_dev.HfstTransducer)``

License
#######

HFST is licensed under Gnu GPL version 3.0.

Troubleshooting
###############

*Pip starts to compile from source although there is a wheel available:*

Try upgrading pip with

``pip3 install --upgrade pip``

or

``python3 -m pip install --upgrade pip``.

Another reason for this can be that
the source package on PyPI is newer (i.e. has a higher version number) than
the corresponding wheel for the given environment.

*Error message "command ... failed with error code ...":*

Try rerunning pip in verbose mode with

``pip3 install --verbose [--upgrade] hfst_dev``

or

``python3 -m pip install --verbose [--upgrade] hfst_dev``

to get more information.

*Error message "error: could not delete ... : permission denied":*

You do not have sufficient rights to install packages. On Mac and Linux, try
installing as super user with

``sudo pip3 install [--upgrade] hfst_dev``

or

``sudo python3 -m pip install [--upgrade] hfst_dev``.

On Windows, reopen Command Prompt/Python command line/IDLE by right-clicking
and choose "Run as administrator", then run pip again.


Links
#####

`HFST project main page <https://hfst.github.io>`_: more information about
the project
