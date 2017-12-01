#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    exit 1 # not yet implemented
    TOOL="python3 ./hfst-compose-intersect.py"
else
    TOOL=$TOOLDIR/hfst-compose-intersect
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
    FFLAG=
    case $i in
        .sfst)
            FFLAG="-f sfst";;
        .ofst)
            FFLAG="-f openfst-tropical";;
        .foma)
            FFLAG="-f foma";;
        *)
            FFLAG=;;
    esac
    if test -f cat$i ; then
        if ! echo "cat|dog" | $TOOLDIR/hfst-calculate $FFLAG > lexicon ; then
            exit 1
        fi
        if ! echo "([catdog]|d:D|c:C)*" | $TOOLDIR/hfst-calculate $FFLAG > rules ; then
            exit 1
        fi
        if ! echo "([catdog]|d:D|c:C)*" | $TOOLDIR/hfst-calculate $FFLAG >> rules ; then
            exit 1
        fi
        if ! $TOOL -1 lexicon -2 rules > test ; then
            exit 1
        fi
        if ! echo "cat|dog|{cat}:{Cat}|{dog}:{Dog}" | $TOOLDIR/hfst-calculate $FFLAG > test2 ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test test2  ; then
            exit 1
        fi
        rm test test2 lexicon rules
    fi
done
