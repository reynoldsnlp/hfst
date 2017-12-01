#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-push-weights.py"
else
    TOOL=$TOOLDIR/hfst-push-weights
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

if ! $TOOL -p initial cat2dog.hfst > test ; then
    exit 1
fi
if ! $TOOLDIR/hfst-compare -s test cat2dog.hfst  ; then
    exit 1
fi
if ! $TOOL -p final cat2dog.hfst > test ; then
    exit 1
fi
if ! $TOOLDIR/hfst-compare -s test cat2dog.hfst  ; then
    exit 1
fi
rm test
