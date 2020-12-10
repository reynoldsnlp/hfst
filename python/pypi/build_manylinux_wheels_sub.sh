#!/bin/bash

## NOTE: This script is intended to be called only by build_manylinux_wheels.sh

set -e -x

echo "Installing dependencies..."
yum update -d1 && yum install -y bison flex
yum install -y pcre pcre-devel  # needed to compile swig
curl https://managedway.dl.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz \
	-o /tmp/swig-4.0.2.tar.gz
pushd /tmp
tar -zxvf swig-4.0.2.tar.gz
cd swig-4.0.2
./configure
make
make install
popd


for PYBIN in /opt/python/*/bin/python;
do
	${PYBIN} -m pip install --upgrade setuptools twine wheel
done

echo "Configuring..."
# make clean
autoreconf -i
./configure --enable-all-tools --enable-fsmbook-tests

echo "Compiling HFST..."
make  # TODO Might not need *all* of this? (Currently fails if you delete this line)

echo "Making flex/yacc files..."
cd libhfst/src/parsers/
make  # Unnecessary after compiling all of HFST, but doesn't hurt

echo "Building libhfst.py..."
cd ../../../python/
/opt/python/cp38-cp38/bin/python setup.py build_ext --inplace

echo "Copying cpp and other files..."
cd pypi/
./copy-files.sh

echo "Building wheels..."
for PYBIN in /opt/python/*/bin/python
do
	${PYBIN} setup.py build_ext --inplace --no-readline
	${PYBIN} setup.py bdist_wheel --no-readline
done
echo "Building source distribution file..."
${PYBIN} setup.py sdist

# Bundle external shared libraries into the wheels
for whl in dist/*.whl
do
    if ! auditwheel show "$whl"; then
        echo "Skipping non-platform wheel $whl"
    else
        auditwheel repair "$whl" --plat "$PLAT" -w /io/python/pypi/dist/
    fi
done

# Install packages and test
cd ../test
for PYBIN in /opt/python/*/bin/python
do
    ${PYBIN} -m pip install hfst --no-index -f /io/python/pypi/dist/
    ./test.sh --python "${PYBIN}"
done
