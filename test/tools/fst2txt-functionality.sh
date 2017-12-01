#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-fst2txt.py"
else
    TOOL=$TOOLDIR/hfst-fst2txt
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

if [ "$srcdir" = "" ]; then
    srcdir="./";
fi

TOOLDIR=$TOOLDIR

cat $srcdir/cat.txt | tr -d '\r' > TMP;
mv TMP $srcdir/cat.txt;

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
    if test -f cat$i ; then
        if ! $TOOL -D < cat$i > test.txt 2> /dev/null ; then
            exit 1
        fi
        if ! diff test.txt $srcdir/cat.txt > /dev/null 2>&1 ; then
            exit 1
        fi
        if ! $TOOL -f dot < cat$i > test.txt 2> /dev/null ; then
            exit 1
        fi
        if which dot > /dev/null 2>&1 ; then
            if ! dot test.txt > /dev/null 2>&1 ; then
                exit 1
            fi
        fi
        if ! $TOOL -f pckimmo < cat$i > test.txt 2> /dev/null ; then
            exit 1
        fi
        if ! $TOOL -f prolog < cat$i > test.txt 2> /dev/null ; then
            exit 1
        fi
        rm test.txt
    fi
fi
done
