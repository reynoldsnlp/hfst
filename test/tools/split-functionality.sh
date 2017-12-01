#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-split.py"
else
    TOOL=$TOOLDIR/hfst-split
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
    if test -f cat2dog$i -a -f dog2cat$i ; then
        if ! (cat cat2dog$i dog2cat$i | $TOOL) ; then
            exit 1
        fi
        if ! ($TOOLDIR/hfst-compare -s 1.hfst cat2dog$i)  ; then
            rm 1.hfst 2.hfst
            exit 1
        fi
        if ! ($TOOLDIR/hfst-compare -s 2.hfst dog2cat$i)  ; then
            rm 1.hfst 2.hfst
            exit 1
        fi
        rm 1.hfst 2.hfst;
    fi
fi
done
