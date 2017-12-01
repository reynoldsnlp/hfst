#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-summarize.py"
else
    TOOL=$TOOLDIR/hfst-summarize
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
    if test -f cat$i ; then
        if ! $TOOL cat$i > test.txt ; then
            exit 1
        fi
        rm test.txt;
    fi
fi
done
