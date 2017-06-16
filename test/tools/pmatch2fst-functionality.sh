#!/bin/sh
TOOLDIR=../../tools/src
if [ "$srcdir" = "" ] ; then
    srcdir=. ;
fi

if ! $TOOLDIR/hfst-pmatch2fst $srcdir/pmatch_blanks.txt > test.pmatch ; then
    exit 1
fi
# Test with any old string
if ! $TOOLDIR/hfst-pmatch test.pmatch < $srcdir/cat.strings > pmatch.out ; then
    exit 1
fi

$TOOLDIR/hfst-pmatch2fst <<< 'set need-separators off regex [\Whitespace]+ EndTag(Q);' > test.pmatch

$TOOLDIR/hfst-pmatch test.pmatch <<< 'a b  c' > pmatch.out
if ! diff pmatch.out - <<< '<Q>a</Q> <Q>b</Q>  <Q>c</Q>' > /dev/null ; then
    exit 1
fi

$TOOLDIR/hfst-pmatch2fst <<< 'set need-separators off regex "\x22" EndTag(Q);' > test.pmatch

$TOOLDIR/hfst-pmatch test.pmatch <<< 'a "b"  c' > pmatch.out
if ! diff pmatch.out - <<< 'a <Q>"</Q>b<Q>"</Q>  c' > /dev/null ; then
    exit 1
fi

$TOOLDIR/hfst-pmatch2fst <<< 'set need-separators off regex "\"" EndTag(Q);' > test.pmatch

$TOOLDIR/hfst-pmatch test.pmatch <<< 'a "b"  c' > pmatch.out
if ! diff pmatch.out - <<< 'a <Q>"</Q>b<Q>"</Q>  c' > /dev/null ; then
    exit 1
fi

$TOOLDIR/hfst-pmatch2fst <<< 'set need-separators off regex {"} EndTag(Q);' > test.pmatch

$TOOLDIR/hfst-pmatch test.pmatch <<< 'a "b"  c' > pmatch.out
if ! diff pmatch.out - <<< 'a <Q>"</Q>b<Q>"</Q>  c' > /dev/null ; then
    exit 1
fi

$TOOLDIR/hfst-pmatch2fst <<< 'set need-separators off regex %" EndTag(Q);' > test.pmatch

$TOOLDIR/hfst-pmatch test.pmatch <<< 'a "b"  c' > pmatch.out
if ! diff pmatch.out - <<< 'a <Q>"</Q>b<Q>"</Q>  c' > /dev/null ; then
    exit 1
fi

rm -f pmatch.out test.pmatch
exit 0
