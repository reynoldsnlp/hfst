#!/bin/bash

if [ -e hfst-${1}-installable ] ; then
    echo "Target directory already exists"; exit 1
fi

function print_help()
{
    echo 'make-installable.sh expects to have the morphology in the'
    echo 'working directory under the name "langname.hfst", where'
    echo '"langname" is the name of the language in question, eg.'
    echo '"french.hfst". Run it like so:'
    echo
    echo './make-installable.sh french fr [-w | --weighted] [--capcase] [--punct]'
    echo
    echo 'fr is the language code'
    echo '-w or --weighted controls whether the analyzer will be weighted'
    echo '--capcase controls whether to compose in a casing handler'
    echo '--punct controls whether to include a punctuation handler'
}

if [ $# -lt 2 ] ; then
    print_help
    exit 1
fi

langname=$1
langcode=$2
shift 2

fst2fstcommand="hfst-fst2fst -O"
capcase="false"
punct="false"

while test -n "$1"; do
    case "$1" in
	""|-h|--help)
	    print_help
	    exit 1
	    ;;
	-w|--weighted)
	    fst2fstcommand="hfst-fst2fst -w"
	    ;;
	--capcase)
	    capcase="true"
	    ;;
	--punct)
	    punct="true"
	    ;;
	*)
	    print_help
	    exit 1
    esac
    shift
done

set -x
mkdir hfst-${langname}-installable

if [ "$punct" == "true" ] || [ "$capcase" == "true"]; then
    hfst-fst2fst -t ${langname}.hfst > ${langname}_tmp.hfst
fi

if [ "$punct" == "true" ]; then
    hfst-strings2fst -j punct.txt | hfst-disjunct -1 - -2 ${langname}_tmp.hfst > ${langname}_with_punct.hfst
    mv ${langname}_with_punct.hfst ${langname}_tmp.hfst
fi

hfst-invert ${langname}_tmp.hfst | $fst2fstcommand > \
    hfst-${langname}-installable/${langcode}-generation.hfst.ol

if [ "$capcase" == "true" ]; then
    hfst-pmatch2fst <<< 'set need-separators off regex (OptDownCase(?, L)) ?*;' | hfst-fst2fst -t | hfst-compose -1 - -2 ${langname}_tmp.hfst > ${langname}_capcase.hfst
    mv ${langname}_capcase.hfst ${langname}_tmp.hfst
fi

$fst2fstcommand ${langname}_tmp.hfst > \
    hfst-${langname}-installable/${langcode}-analysis.hfst.ol

sed s/LANGCODE/${langcode}/g < analyze.sh > hfst-${langname}-installable/${langname}-analyze-words
sed s/LANGCODE/${langcode}/g < generate.sh > hfst-${langname}-installable/${langname}-generate-words
sed -e s/LANGNAME/${langname}/g -e s/LANGCODE/${langcode}/g < Makefile-skeleton > \
    hfst-${langname}-installable/Makefile

typeset -u firstletter=${langname:0:1}
rest=${langname:1}

sed -e s/Langname/$firstletter$rest/g -e s/LANGNAME/${langname}/g < README-skeleton > \
    hfst-${langname}-installable/README

sed -e s/LANG/${langname}.hfst/g < tokenizer-skeleton > ${langcode}-tokenizer.txt
hfst-pmatch2fst ${langcode}-tokenizer.txt > hfst-${langname}-installable/${langcode}-tokenize.pmatch
rm -f ${langcode}-tokenizer.txt ${langname}_tmp.hfst
