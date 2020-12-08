#!/bin/bash

set -e -x

PYTHON_EXECUTABLES="python3.6 python3.7 python3.8 python3.9"

echo "STEP Configuring..."
cd ../../
# make clean
autoreconf -i  # Is this necessary?
./configure --enable-all-tools --with-readline --enable-fsmbook-tests

echo "STEP Making flex/yacc files..."
cd libhfst/src/parsers/
make

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
cd ../test
for p in ${PYTHON_EXECUTABLES}; do
	${p} -m pip install hfst --no-index -f ../pypi/dist/ --force-reinstall
	abs_p=$(which ${p})
	./test.sh --python ${abs_p}
done
