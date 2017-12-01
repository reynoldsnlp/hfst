#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-minimize.py"
else
    TOOL=$TOOLDIR/hfst-minimize
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
    if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
        if test -f non_minimal$i ; then
            if ! $TOOL non_minimal$i > test ; then
                exit 1
            fi
            if ! $TOOLDIR/hfst-compare -s test non_minimal$i  ; then
                exit 1
            fi
            rm test;
        fi
    fi
done
