
*******************
Package description
*******************

Package ``hfst`` contains python bindings for `HFST <https://hfst.github.io>`_
(Helsinki Finite-State Technology) C++ library. HFST toolkit is intended for
processing natural language morphologies. The toolkit is demonstrated by
wide-coverage implementations of a number of languages of varying
morphological complexity.

Requirements
############

Wheels are offered for python versions 2.7, 3.4, 3.5 and 3.6 for Windows and Mac OS X.
We currently offer only 64-bit wheels for Windows. They also require a 64-bit
python to work correctly. Wheels for Mac are compiled as universal binaries
that work on both 32- and 64-bit environments. OS X must be 10.6 or higher.

For Linux users, we recommend using the `Debian packages
<https://kitwiki.csc.fi/twiki/bin/view/KitWiki/HfstPython#Option_1_Installing_the_debian_p>`_.
Compiling from source for Linux requires at least: swig (tested with version 3.0.5)
and C++ compiler (tested with gcc 5.4.0), both located on system PATH; setuptools package
for python (tested with version 28.8.0); readline and getline libraries for C++ compiler.


Installation
############

We recommend using ``pip`` tool for installation. For python version 3, it is
usually named ``pip3``, plain ``pip`` being used for python version 2.

``pip3 install [--upgrade] hfst``
``pip install [--upgrade] hfst``

Starting from python 3.4.0 and python 2.7.9, pip is included by default
and can be called via python with option ``-m pip``.

``python3 -m pip install [--upgrade] hfst``
``python -m pip install [--upgrade] hfst``

The commands above are run in a shell/terminal/command prompt, but they can
also be run on python command line or via a graphical user interface 
(e.g. IDLE) with pip.main that takes arguments in a list:

| ``import pip``
| ``pip.main(['install','--upgrade','hfst'])``


Alternative `installation instructions <https://kitwiki.csc.fi/twiki/bin/view/KitWiki/HfstPython>`_
are given on our KitWiki pages.

Documentation
#############

See Doxygen-generated `package documentation <https://hfst.github.io/python>`_
on our Github pages. In python, you can also use ``dir`` and ``help``
commands, e.g.:

``dir(hfst)``

``help(hfst.HfstTransducer)``

License
#######

HFST is licensed under Gnu GPL version 3.0.

Troubleshooting
###############

(In the commands below, ``python[3]`` means either ``python`` or ``python3`` depending of the version of python you are using;
the same goes for ``pip[3]`` meaning ``pip`` or ``pip3``.)

*Pip starts to compile from source although there is a wheel available:*

Try upgrading pip with ``pip[3] install --upgrade pip`` or 
``python[3] -m pip install --upgrade pip``.
Another reason for this can be that
the source package on PyPI is newer (i.e. has a higher version number) than
the corresponding wheel for the given environment. Report this via our
`issue tracker <https://github.com/hfst/hfst/issues/>`_ so a fresh wheel
will be created.

*Error message "command ... failed with error code ...":*

Try rerunning pip in verbose mode with
``pip[3] install --verbose [--upgrade] hfst`` or
``python[3] -m pip install --verbose [--upgrade] hfst``
to get more information.

*Error message "error: could not delete ... : permission denied":*

You do not have sufficient rights to install packages. On Mac and Linux, try
installing as super user with ``sudo pip[3] install [--upgrade] hfst`` or
``sudo python[3] -m pip install [--upgrade] hfst``.
On Windows, reopen Command Prompt/Python command line/IDLE by right-clicking
and choose "Run as administrator", then run pip again.


Links
#####

`HFST project main page <https://hfst.github.io>`_: more information about
the project

`Github issue tracker <https://github.com/hfst/hfst/issues/>`_: for comments,
feature requests and bug reports

