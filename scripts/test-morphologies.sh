#!/bin/sh

test_case()
{
    expected=$1-analyze-words.output
    echo $2 | $1-analyze-words | cut -f 2- > tmp
    if test -f "$expected" ; then
	if ! diff tmp $expected > /dev/null; then
	    echo "$1: input \"$2\" (space-separated words) differs from expected"
	fi
    fi
    echo $2 | perl -pe 's/ /\n/;' | $1-analyze-words | cut -f 2- > tmp
    if test -f "$expected" ; then
	if ! diff tmp $expected > /dev/null; then
	    echo "$1: input \"$2\" (line-separated words) differs from expected"
	fi
    fi
}

test_lang()
{
    test_case $1 "$2"
    var=`echo $2 | perl -pe 's/^(.)/\l$1/g;'`
    test_case $1 "$var"
    var=`echo $2 | perl -pe 's/ (.)/ \u$1/g;'`
    test_case $1 "$var"
}

test_lang "english" "This is a test."
test_lang "finnish" "Tämä on testi."
#test_lang "french" " "
#test_lang "german" " "
#test_lang "italian" " "
#test_lang "swedish" " "
#test_lang "turkish" " "
