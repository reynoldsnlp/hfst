#!/bin/bash
trdir=TRPATH
if [ ! -d "$trdir" ] ; then
    echo $trdir not found
    exit 1
fi
if [ ! -e "$trdir"/LANGCODE-generation.hfst.ol ] ; then
    echo "$trdir/LANGCODE-generation.hfst.ol not found"
    exit 1
fi
if ! command -v hfst-lookup 2> /dev/null; then
    echo "hfst-lookup not found on your system."
    echo "HFST is available from https://github.com/hfst/hfst."
    exit 1
fi
if [ "$1" == "--help" ] ; then
    echo "Generates surface forms from morphological analyses from standard input."
    echo "One analysis per line."
    exit 0
fi

hfst-lookup -p $trdir/LANGCODE-generation.hfst.ol | cut -f1,2
