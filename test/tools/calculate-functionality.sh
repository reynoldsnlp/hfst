#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-calculate.py"
else
    TOOL=$TOOLDIR/hfst-calculate
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
    FFLAG=
    case $i in
        .sfst)
            FFLAG="-f sfst"
	    if ! ($TOOLDIR/hfst-format --list-formats | grep "sfst" > /dev/null) ; then
		continue;
	    fi;;
        .ofst)
            FFLAG="-f openfst-tropical"
	    if ! ($TOOLDIR/hfst-format --list-formats | grep "openfst-tropical" > /dev/null) ; then
		continue;
	    fi;;
        .foma)
            FFLAG="-f foma"
	    if ! ($TOOLDIR/hfst-format --list-formats | grep "foma" > /dev/null) ; then
		continue;
	    fi;;
        *)
            FFLAG=;;
    esac
    if test -f 4toINFcats$i ; then
        if ! echo "catcatcat(cat)+" | $TOOL $FFLAG > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s 4toINFcats$i test  ; then
            exit 1
        fi
        rm test
    fi
    if test -f cat2dog$i ; then
        if ! echo "{cat}:{dog}" | $TOOL $FFLAG > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s cat2dog$i test  ; then
            exit 1
        fi
        rm test
    fi
done
