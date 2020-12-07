#!/bin/bash

set -e -u -x

echo "STEP Configuring..."
cd ../../
make clean
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
./copy_files.sh
echo "STEP Building binary distribution wheels..."
for p in python35 python36 python37 python38 python39; do
	$p setup.py build_ext --inplace
	$p setup.py bdist_wheel
done

echo "STEP Building source distribution..."
$p setup.py sdist

echo "STEP Running tests..."
cd ../
for p in python35 python36 python37 python38 python39; do
	$p -m pip install hfst --no-index -f pypi/dist/
	$(cd test && ./test.sh --python $p)
done
