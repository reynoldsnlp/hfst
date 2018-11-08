# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

for type in [hfst_dev.ImplementationType.SFST_TYPE, hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE, hfst_dev.ImplementationType.FOMA_TYPE]:
    if hfst_dev.HfstTransducer.is_implementation_type_available(type):
        
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('foo')
        tok.add_skip_symbol('b')
        assert tok.tokenize('foobar') == (('foo', 'foo'), ('a', 'a'), ('r', 'r'))
        assert tok.tokenize_one_level('foobar') == ('foo', 'a', 'r')
        assert tok.tokenize('foobar','barfoo') == (('foo', 'a'), ('a', 'r'), ('r', 'foo'))
        
        tok = hfst_dev.HfstTokenizer()
        
        tok = hfst_dev.HfstTokenizer()
        tok.add_skip_symbol('foo')
        assert tok.tokenize_one_level('foofofoobar') == ('f', 'o', 'b', 'a', 'r')
        
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('foo')
        tok.add_skip_symbol('fo')
        assert tok.tokenize_one_level('foofo') == ('foo',)
        
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('fo')
        tok.add_skip_symbol('foo')
        assert tok.tokenize_one_level('foofo') == ('fo',)
        
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('fo')
        tok.add_multichar_symbol('foo')
        tok.add_multichar_symbol('of')
        assert tok.tokenize_one_level('fofoofooof') == ('fo', 'foo', 'foo', 'of')
        
        tok = hfst_dev.HfstTokenizer()
        t = tok.tokenize('foobar')
        assert t == (('f', 'f'), ('o', 'o'), ('o', 'o'), ('b', 'b'), ('a', 'a'), ('r', 'r'))
        
        tok = hfst_dev.HfstTokenizer()
        t = tok.tokenize_one_level('foobar')
        assert t == ('f', 'o', 'o', 'b', 'a', 'r')
        
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('foo')
        tok.add_skip_symbol('b')
        assert tok.tokenize('foobar','Foobar') == \
            (('foo', 'F'), ('a', 'o'), ('r', 'o'), ('@_EPSILON_SYMBOL_@', 'a'), ('@_EPSILON_SYMBOL_@', 'r'))
        
        tok = hfst_dev.HfstTokenizer()
        assert tok.tokenize_space_separated('f o o b a r') == \
            (('f', 'f'), ('o', 'o'), ('o', 'o'), ('b', 'b'), ('a', 'a'), ('r', 'r'))
        assert tok.tokenize_space_separated('foo b a r') == \
            (('foo', 'foo'), ('b', 'b'), ('a', 'a'), ('r', 'r'))
        assert tok.tokenize_space_separated('f o o bar') == \
            (('f', 'f'), ('o', 'o'), ('o', 'o'), ('bar', 'bar'))
        assert tok.tokenize_space_separated('foo bar') == \
            (('foo', 'foo'), ('bar', 'bar'))
        assert tok.tokenize_space_separated('foobar') == \
            (('foobar', 'foobar'),)

        if int(sys.version[0]) > 2:
            try:
                hfst_dev.HfstTokenizer.check_utf8_correctness('föö')
            except hfst_dev.exceptions.IncorrectUtf8CodingException as e:
                assert(False)
