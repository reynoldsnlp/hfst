#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-substitute.py"
else
    TOOL=$TOOLDIR/hfst-substitute
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

for i in "" .sfst .ofst .foma; do
if ((test -z "$i") || $TOOLDIR/hfst-format --list-formats | grep $i > /dev/null); then
    if test -f cat$i -a -f dog$i ; then
        if ! $TOOL -s cat$i -F $srcdir/cat2dog.substitute > test ; then
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test dog$i  ; then
            exit 1
        fi
        rm test
        $TOOL -s cat$i -f c -t d |\
            $TOOL -s -f a -t o |\
            $TOOL -s -f t -t g > test
        if test $? -ne 0 ; then 
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test dog$i ; then
            exit 1
        fi
    fi
    if test -f another_epsilon$i -a -f epsilon$i ; then
        if ! $TOOL -s -i another_epsilon$i -f '@@ANOTHER_EPSILON@@' -t '@0@' > test ; then
            echo "fail: could not substitute"
            exit 1
        fi
        if ! $TOOLDIR/hfst-compare -s test epsilon$i  ; then
            echo "fail: test and epsilon"$i" differ"
            exit 1
        fi
        if $TOOLDIR/hfst-summarize --verbose test 2> /dev/null | grep "sigma" | grep '@@ANOTHER_EPSILON@@' > /dev/null ; then
            echo "fail: @@ANOTHER_EPSILON@@ is still in the alphabet after substitution"
            exit 1
        fi
        rm test
    fi
    # Disable test until option -T works in hfst-substitute
    #if test -f cat$i -a -f substituted_transducer$i -a -f substituting_transducer$i; then
    #    if ! $TOOLDIR/hfst-substitute -s cat$i -f 'a:a' -T $srcdir/substituting_transducer$i > test ; then
    #        exit 1
    #    fi
    #    if ! $TOOLDIR/hfst-compare -s test substituted_transducer$i  ; then
    #        exit 1
    #    fi
    #    rm test
    #fi
fi
done
