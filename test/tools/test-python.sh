#!/bin/sh

export srcdir=`pwd`

for tool in calculate compare compose concatenate conjunct determinize \
	    disjunct format fst2strings head invert minimize \
	    project prune-alphabet repeat reverse subtract tail txt2fst;
do
    printf "%-20s" $tool"..."
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


# todo: fix these:
# pmatch2fst, regexp2fst

# todo: not yet implemented:
# compose-intersect flookup fst2txt lexc-compiler-flags lexc-compiler
# lexc-wrapper lookup optimized-lookup pmatch proc push-weights
# remove-epsilons reweight shuffle split strings2fst substitute
# subtract summarize symbol-harmonization tokenize-backtrack
# tokenize-flushing tokenize

# fst2fst-functionality doesn't exist
