#!/bin/sh
TOOLDIR=../../tools/src
TOOL=

if [ "$1" = '--python' ]; then
    TOOL="python3 ./hfst-pmatch2fst.py"
else
    TOOL=$TOOLDIR/hfst-pmatch2fst
    if ! test -x $TOOL; then
	exit 0;
    fi
fi

if [ "$srcdir" = "" ] ; then
    srcdir=. ;
fi

if ! $TOOL $srcdir/pmatch_blanks.txt > test.pmatch ; then
    exit 1
fi
# Test with any old string
if ! $TOOLDIR/hfst-pmatch --newline test.pmatch < $srcdir/cat.strings > pmatch.out ; then
    exit 1
fi

echo 'set need-separators off regex [\Whitespace]+ EndTag(Q);' | $TOOL > test.pmatch

echo 'a b  c' | $TOOLDIR/hfst-pmatch --newline test.pmatch > pmatch.out
if ! echo '<Q>a</Q> <Q>b</Q>  <Q>c</Q>' | diff pmatch.out - > /dev/null ; then
    exit 1
fi

echo 'set need-separators off regex "\x22" EndTag(Q);' | $TOOL > test.pmatch

echo 'a "b"  c' | $TOOLDIR/hfst-pmatch --newline test.pmatch > pmatch.out
if ! echo 'a <Q>"</Q>b<Q>"</Q>  c' | diff pmatch.out - > /dev/null ; then
    exit 1
fi

echo 'set need-separators off regex "\"" EndTag(Q);' | $TOOL > test.pmatch

echo 'a "b"  c' | $TOOLDIR/hfst-pmatch --newline test.pmatch > pmatch.out
if ! echo 'a <Q>"</Q>b<Q>"</Q>  c' | diff pmatch.out - > /dev/null ; then
    exit 1
fi

echo 'set need-separators off regex {"} EndTag(Q);' | $TOOL > test.pmatch

echo 'a "b"  c' | $TOOLDIR/hfst-pmatch --newline test.pmatch > pmatch.out
if ! echo 'a <Q>"</Q>b<Q>"</Q>  c' | diff pmatch.out - > /dev/null ; then
    exit 1
fi

echo 'set need-separators off regex %" EndTag(Q);' | $TOOL > test.pmatch

echo 'a "b"  c' | $TOOLDIR/hfst-pmatch --newline test.pmatch > pmatch.out
if ! echo 'a <Q>"</Q>b<Q>"</Q>  c' | diff pmatch.out - > /dev/null ; then
    exit 1
fi

rm -f pmatch.out test.pmatch
exit 0
