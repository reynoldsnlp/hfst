#!/bin/bash
trdir=TRPATH
if [ ! -d "$trdir" ] ; then
    echo $trdir not found
    exit 1
fi
if [ ! -e "$trdir"/LANGCODE-analysis.hfst.ol ] ; then
    echo "$trdir/LANGCODE-analysis.hfst.ol not found"
    exit 1
fi
if command -v hfst-tokenize 2 > /dev/null; then
    echo "hfst-tokenize not found on your system"
    echo "HFST is available from https://github.com/hfst/hfst"
    exit 1
fi
if command -v hfst-lookup 2 > /dev/null; then
    echo "hfst-lookup not found on your system"
    echo "HFST is available from https://github.com/hfst/hfst"
    exit 1
fi
if [ "$1" == "--help" ] ; then
    echo "Provides a morphological analysis of text from standard input."
    echo "Input can be running text, in which case it is tokenized first."
    exit 0
fi

hfst-tokenize $trdir/LANGCODE-tokenize.pmatch |
    hfst-lookup -p $trdir/LANGCODE-analysis.hfst.ol |
    cut -f1,2
