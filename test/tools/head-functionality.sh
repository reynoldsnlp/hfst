#!/bin/sh
TOOLDIR=../../tools/src
TOOL=
FORMAT_TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-head.py"
    FORMAT_TOOL="python3 ./hfst-format.py"
else
    TOOL=$TOOLDIR/hfst-head
    FORMAT_TOOL=$TOOLDIR/hfst-format
    for tool in $TOOL $FORMAT_TOOL; do
	if ! test -x $tool; then
	    exit 0;
	fi
    done
fi

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $FORMAT_TOOL --list-formats | grep $i > /dev/null); then
    if test -f cat2dog$i -a -f dog2cat$i ; then
        if ! cat cat2dog$i dog2cat$i | $TOOL -n 1 > test ; then
            exit 1
        fi
        if ! $COMPARE_TOOL -s test cat2dog$i  ; then
            exit 1
        fi
        rm test;
        if ! cat cat2dog$i dog2cat$i | $TOOL -n -1 > test ; then
            exit 1
        fi
        if ! $COMPARE_TOOL -s test cat2dog$i  ; then
            exit 1
        fi
        rm test;
    fi
fi
done
