#!/bin/bash

echo "Configuring..."
cd ../../
make clean
autoreconf -i  # Is this necessary?
./configure --enable-all-tools --with-readline --enable-fsmbook-tests
echo "Making flex/yacc files..."
cd libhfst/src/parsers/
make
echo "Building libhfst.py..."
cd ../../../python/
python3 setup.py build_ext --inplace
echo "Copying cpp and other files..."
cd pypi/
./copy_files.sh
echo "Building wheels..."
for p in python35 python36 python37 python38 python39; do
	$p setup.py build_ext --inplace
	$p setup.py bdist_wheel
done

$p setup.py sdist
