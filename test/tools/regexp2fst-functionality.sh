#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-regexp2fst.py"
else
    TOOL=$TOOLDIR/hfst-regexp2fst
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

if [ "$srcdir" = "" ] ; then
    srcdir=. ;
fi

for i in sfst openfst-tropical foma; do
    
    if ! ($TOOLDIR/hfst-format --list-formats | grep $i > /dev/null) ; then
	continue;
    fi
    
    if ! $TOOL -f $i $srcdir/cats_and_dogs.xre > test ; then
        exit 1
    fi
    
    rm test;
    if ! $TOOL -S -f $i $srcdir/cats_and_dogs_semicolon.xre > test ; then
        exit 1
    fi
    
    rm test;
    if ! $TOOL -f $i $srcdir/at_file_quote.$i.xre > test.fst ; then
        exit 1
    fi
    
    if ! $TOOL -f $i $srcdir/not-contains-a.xre > test.fst ; then
        exit 1
    fi
    
    if ! $TOOL -S -f $i $srcdir/not-contains-a-comment-emptyline.xre > test.fst ; then
        exit 1
    fi
    
    if ! $TOOL -f $i $srcdir/parallel-left-arrow.xre > test.fst ; then
        exit 1
    fi
    
    if ! $TOOL -S -f $i $srcdir/parallel-left-arrow-multicom-emptyline.xre > test.fst ; then
        exit 1
    fi

    if ! $TOOL -S -f $i $srcdir/left-arrow-with-semicolon-comment.xre > test.fst ; then
        exit 1
    fi

    if ! $TOOL -S -f $i $srcdir/left-arrow-with-semicolon-many-comments.xre > test.fst ; then
        exit 1
    fi

    # Empty input and input containing only comments
    if (echo "" | $TOOL -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi
    if (echo "" | $TOOL -S -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi
    if (echo ";" | $TOOL -S -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi
    if (echo "! A comment" | $TOOL -S -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi
    if (echo "  ! A comment" | $TOOL -S -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi
    if (echo "! A comment" | $TOOL -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi
    if (echo "  ! A comment" | $TOOL -f $i > test.fst 2> /dev/null) ; then
        exit 1
    fi

done

rm -f test.fst
exit 0
