#!/bin/bash

set -e -x

echo "Cleaning old files..."
# TODO are there others?
yes | rm -f *.cpp *.i _libhfst*.so ../_libhfst*.so
yes | rm -fr back-ends/ build/ dist/ libhfst* hfst*
