#!/bin/sh
TOOLDIR=../../tools/src
CALCULATE_TOOL=
FORMAT_TOOL=

if [ "$1" = '--python' ]; then
    CALCULATE_TOOL="python3 ./hfst-calculate.py"
    FORMAT_TOOL="python3 ./hfst-format.py"
else
    CALCULATE_TOOL=$TOOLDIR/hfst-calculate
    FORMAT_TOOL=$TOOLDIR/hfst-format
    if ! test -x $CALCULATE_TOOL; then
	exit 0;
    fi
    if ! test -x $FORMAT_TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
    FFLAG=
    case $i in
        .sfst)
            FFLAG="-f sfst"
	    if ! ($FORMAT_TOOL --list-formats | grep "sfst" > /dev/null) ; then
		continue;
	    fi;;
        .ofst)
            FFLAG="-f openfst-tropical"
	    if ! ($FORMAT_TOOL --list-formats | grep "openfst-tropical" > /dev/null) ; then
		continue;
	    fi;;
        .foma)
            FFLAG="-f foma"
	    if ! ($FORMAT_TOOL --list-formats | grep "foma" > /dev/null) ; then
		continue;
	    fi;;
        *)
            FFLAG=;;
    esac
    if test -f 4toINFcats$i ; then
        if ! echo "catcatcat(cat)+" | $CALCULATE_TOOL $FFLAG > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s 4toINFcats$i test  ; then
            exit 1
        fi
        rm test
    fi
    if test -f cat2dog$i ; then
        if ! echo "{cat}:{dog}" | $CALCULATE_TOOL $FFLAG > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s cat2dog$i test  ; then
            exit 1
        fi
        rm test
    fi
done
