#!/bin/sh

# fst2fst-functionality doesn't exist
# pmatch2fst...
# regexp2fst...

export srcdir=`pwd`

for tool in calculate compare compose concatenate conjunct determinize \
	    disjunct format fst2strings head invert minimize \
	    project prune-alphabet repeat reverse tail txt2fst;
do
    printf $tool"... "
    ./$tool-functionality.sh --python
    retval=$?
    if [ $retval -eq 0 ]; then
	printf "pass\n"
    elif [ $retval -eq 77 ]; then
	printf "skip\n";
    else
	printf "fail\n"
    fi
done
