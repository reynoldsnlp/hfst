#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-format.py"
else
    TOOL=$TOOLDIR/hfst-format
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

echo '0 1 a b
1' > TMP;

if $TOOL --test-format sfst; then
    if echo TMP | $TOOLDIR/hfst-txt2fst -f sfst > test ; then
	if ! $TOOL test > TMP1 ; then
	    exit 1
	fi
	echo "Transducers in test are of type SFST (1.4 compatible)" > TMP2
	if ! diff TMP1 TMP2 ; then
	    exit 1
	fi
    fi
fi

if $TOOL --test-format openfst-tropical; then
    if echo TMP | $TOOLDIR/hfst-txt2fst -f openfst-tropical \
	> test ; then
	if ! $TOOL test > TMP1 ; then
	    exit 1
	fi
	echo "Transducers in test are of type OpenFST, std arc,"\
             "tropical semiring" > TMP2
	if ! diff TMP1 TMP2 ; then
	    exit 1
	fi
    fi
fi

if $TOOL --test-format foma; then
    if echo TMP | $TOOLDIR/hfst-txt2fst -f foma > test ; then
	if ! $TOOL test > TMP1 ; then
	    exit 1
	fi
	echo "Transducers in test are of type foma" > TMP2
	if ! diff TMP1 TMP2 ; then
	    exit 1
	fi
    fi
fi

rm -f test
rm -f TMP
rm -f TMP1
rm -f TMP2
