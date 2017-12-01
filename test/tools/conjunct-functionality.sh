#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-conjunct.py"
else
    TOOL=$TOOLDIR/hfst-conjunct
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
    if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
        if test -f cat_or_dog$i -a -f cat$i ; then
            if ! $TOOL cat_or_dog$i cat$i > test ; then
                exit 1
            fi
            if ! $TOOLDIR/hfst-compare -s test cat$i  ; then
                exit 1
            fi
            rm test;
        fi
    fi
done
