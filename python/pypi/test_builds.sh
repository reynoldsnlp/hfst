#!/bin/bash

# Run tests using all python interpreters given
# Usage: ./test_builds.sh path/to/python1 path/to/python2 ...

cd ../test
for py in "$@"; do
	${py} -c "import sys; print(sys.executable)"
	${py} -m pip install --user --no-index -f ../pypi/dist/ --force-reinstall hfst
	abs_py=$(which "${p}")
	./test.sh --python "${abs_py}" --verbose
	${py} -m pip uninstall -y hfst
done