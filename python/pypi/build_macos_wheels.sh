#!/bin/bash

set -e -x

PYTHON_EXECUTABLES="python3.6 python3.7 python3.8 python3.9"

for p in ${PYTHON_EXECUTABLES}; do
	${p} -m pip install --user --upgrade setuptools twine wheel
	# ${p} -m pip uninstall hfst
done

# echo "STEP Cleaning old files..."
# ./clean.sh

echo "STEP Configuring..."
cd ../../
autoreconf -i  # Is this necessary?
./configure --enable-all-tools --with-readline --enable-fsmbook-tests
# make clean
make  # is this necessary?

echo "STEP Making flex/yacc files..."
cd libhfst/src/parsers/
make  # this is unnecessary if `make` is already called in the root dir, but it doesn't hurt

echo "STEP Building libhfst.py..."
cd ../../../python/
python3 setup.py build_ext --inplace

echo "STEP Copying cpp and other files..."
cd pypi/
./copy-files.sh

echo "STEP Building binary distribution wheels..."
for p in ${PYTHON_EXECUTABLES}; do
	${p} setup.py build_ext --inplace
	${p} setup.py bdist_wheel
done

echo "STEP Building source distribution..."
${p} setup.py sdist

echo "STEP Running tests..."
./test_builds.sh ${PYTHON_EXECUTABLES}