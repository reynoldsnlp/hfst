#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-project.py"
else
    TOOL=$TOOLDIR/hfst-project
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in  .hfst .sfst .ofst .foma; do
    if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
        if test -f cat2dog$i -a -f cat$i -a -f dog$i ; then
            if ! $TOOL -p input cat2dog$i > test ; then
                exit 1
            fi
            if ! $TOOLDIR/hfst-compare -s test cat$i  ; then
                exit 1
            fi
            if ! $TOOL -p output cat2dog$i > test ; then
                exit 1
            fi
            if ! $TOOLDIR/hfst-compare -s test dog$i  ; then
                exit 1
            fi
            rm test;
	    for j in input output; do
	        if ! $TOOL -p $j cat2dog$i > test ; then
		    exit 1
	        fi
	        if ! $TOOLDIR/hfst-concatenate test unk2unk$i > concatenation; then
		    exit 1
	        fi
	    done
        fi
        # test that the input/output side alphabet is present, too
        if ! $TOOLDIR/hfst-fst2txt concatenation | egrep -q "d|o|g" ; then
	    echo "FAIL: The alphabet of the output side is not present" $i;
	    exit 1
        fi
        if ! $TOOL -p $j concatenation > concatenation.projection; then
	    exit 1;
        fi
        # test that there are no unknowns in projection
        if $TOOLDIR/hfst-fst2txt concatenation.projection | grep -q "@_UNKNOWN_SYMBOL_@" ; then
	    echo "FAIL: Unknowns in " $j " projection (should be identities)" $i;
	    exit 1
        fi
    fi
done
rm concatenation concatenation.projection

