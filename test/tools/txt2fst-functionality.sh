#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-txt2fst.py"
else
    TOOL=$TOOLDIR/hfst-txt2fst
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
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
        if ! $TOOL $FFLAG $srcdir/cat.txt > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test cat$i  ; then
            exit 1
        fi
        if ! $TOOL --prolog $FFLAG $srcdir/cat.prolog > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test cat$i  ; then
            exit 1
        fi
        rm test
    fi
fi
done

$TOOL -C -f openfst-tropical -i negative_epsilon_cycles.txt > /dev/null 2> test;
if ! test `grep 'warning' test | wc -l` = '2'; then
    exit 1
fi
$TOOL -C -f openfst-tropical -i no_negative_epsilon_cycles.txt > /dev/null 2> test;
if ! test `grep 'warning' test | wc -l` = '0'; then
    exit 1
fi
