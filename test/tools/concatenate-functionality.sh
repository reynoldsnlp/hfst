#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-concatenate.py"
else
    TOOL=$TOOLDIR/hfst-concatenate
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
    if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
        if test -f cat$i -a -f dog$i ; then
            if ! $TOOL cat$i dog$i > test ; then
                exit 1
            fi
            if ! $TOOLDIR/hfst-compare -s test catdog$i  ; then
                exit 1
            fi
            rm test;
        fi
    fi
done
