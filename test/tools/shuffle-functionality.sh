#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-shuffle.py"
else
    TOOL=$TOOLDIR/hfst-shuffle
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

if ! [ -x $TOOLDIR/hfst-shuffle ]; then
    exit 0;
fi

for i in .sfst .ofst .foma; do
    if ! $TOOLDIR/hfst-format --test-format `echo $i | sed "s/.//"`; then
	continue;
    fi

    if ! $TOOL ab$i bc$i > TMP; then
	rm TMP;
	exit 1;
    else
	if ! $TOOLDIR/hfst-compare TMP ab_shuffle_bc$i > /dev/null 2>&1; then
	    rm TMP;
	    exit 1;
	fi
    fi
    if ! $TOOL id$i id$i > TMP; then
	rm TMP;
	exit 1;
    else
	if ! $TOOLDIR/hfst-compare TMP id_shuffle_id$i > /dev/null 2>&1; then
	    rm TMP;
	    exit 1;
	fi
    fi
    if ! $TOOL aid$i idb$i > TMP; then
	rm TMP;
	exit 1;
    else
	if ! $TOOLDIR/hfst-compare TMP aid_shuffle_idb$i > /dev/null 2>&1; then
	    rm TMP;
	    exit 1;
	fi
    fi
    if $TOOL a2b$i ab$i > /dev/null 2>&1; then
	rm TMP;
	exit 1;
    fi
    rm TMP;
done
