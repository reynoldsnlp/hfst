#!/bin/sh

export srcdir=`pwd`

for tool in calculate compare compose compose-intersect concatenate conjunct determinize \
	    disjunct format fst2strings fst2txt head invert minimize pmatch2fst pmatch \
	    project prune-alphabet push-weights regexp2fst remove-epsilons \
	    repeat reverse shuffle split strings2fst substitute subtract tail txt2fst;
do
    printf "%-25s" $tool"..."
    ./$tool-functionality.sh --python
    retval=$?
    if [ $retval -eq 0 ]; then
	printf '%s\n' 'pass'
    elif [ $retval -eq 77 ]; then
	printf '%s\n' 'skip'
    else
	printf '%s\n' 'fail'
    fi
done

# one problem with python: lexc-compiler: basic.lowercase-lexicon-end.lexc

# flookup
# lookup
# optimized-lookup
# proc
# reweight
# summarize
# symbol-harmonization
# tokenize-backtrack
# tokenize-flushing
# tokenize

# fst2fst-functionality doesn't exist
# lexc-wrapper not supported any more
# lexc-compiler-flags not carried out even with c++
