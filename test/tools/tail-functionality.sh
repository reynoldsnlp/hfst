#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-tail.py"
else
    TOOL=$TOOLDIR/hfst-tail
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
    if test -f cat2dog$i -a -dog2cat$i ; then
        if ! cat cat2dog$i dog2cat$i | $TOOLDIR/hfst-tail -n 1 > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test dog2cat$i  ; then
            exit 1
        fi
        rm test;
        if ! cat cat2dog$i dog2cat$i | $TOOL -n +2 > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test dog2cat$i  ; then
            exit 1
        fi
        rm test;
    fi
fi
done
