# -*- coding: utf-8 -*-
# The examples given in doxygen documentation
from __future__ import print_function
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

types = []
if hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.SFST_TYPE):
    types.append(hfst_dev.ImplementationType.SFST_TYPE)
if hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE):
    types.append(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE)
if hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.FOMA_TYPE):
    types.append(hfst_dev.ImplementationType.FOMA_TYPE)

for type in types:
    if hfst_dev.HfstTransducer.is_implementation_type_available(type):

        hfst_dev.set_default_fst_type(type)
        
        # StreamIsClosedException
        try:
            tr = hfst_dev.regex('foo')
            outstr = hfst_dev.HfstOutputStream(filename='testfile')
            outstr.close()
            outstr.write(tr)
        except hfst_dev.exceptions.StreamIsClosedException:
            print("Could not write transducer: stream to file was closed.")
            
        # TransducerIsCyclicException
        transducer = hfst_dev.regex('[a:b]*')
        try:
            results = transducer.extract_paths(output='text')
            print("The transducer has %i paths:" % len(results))
            print(results)
        except hfst_dev.exceptions.TransducerIsCyclicException:
            print("The transducer is cyclic and has an infinite number of paths. Some of them:")
            results = transducer.extract_paths(output='text', max_cycles=5)
            print(results)
        
        # NotTransducerStreamException
        f = open('foofile', 'w')
        f.write('This is an ordinary text file.\n')
        f.close()
        try:
            instr = hfst_dev.HfstInputStream('foofile')
            tr = instr.read()
            print(tr)
            instr.close()
        except hfst_dev.exceptions.NotTransducerStreamException:
            print("Could not print transducer: the file does not contain binary transducers.")
        
        f = open('testfile1.att', 'w')
        f.write('0 1 a b\n1 2 c\n2\n')
        f.close()
        f = open('testfile1.att', 'r')
        try:
            tr = hfst_dev.read_att_transducer(f)
        except hfst_dev.exceptions.NotValidAttFormatException:
            print('Could not read file: it is not in valid ATT format.')
        f.close()
        
        # StateIsNotFinalException
        tr = hfst_dev.HfstIterableTransducer()
        tr.add_state(1)
        # An exception is thrown as state number 1 is not final
        try:
            w = tr.get_final_weight(1)
        except hfst_dev.exceptions.StateIsNotFinalException:
            print("State is not final.")

        # ContextTransducersAreNotAutomataException
        # try:
        #    tr = hfst_dev.regex('a -> b || c:c __ c:d')
        # except hfst_dev.exceptions.ContextTransducersAreNotAutomataException:
        #    print("Context transducers must be automata.")
        
        # TransducersAreNotAutomataException
        tr1 = hfst_dev.regex('foo:bar')
        tr2 = hfst_dev.regex('bar:baz')
        try:
            tr1.cross_product(tr2)
        except hfst_dev.exceptions.TransducersAreNotAutomataException:
            print('Transducers must be automata in cross product.')
        
        # StateIndexOutOfBoundsException
        tr = hfst_dev.HfstIterableTransducer()
        tr.add_state(1)
        try:
            w = tr.get_final_weight(2)
        except hfst_dev.exceptions.StateIndexOutOfBoundsException:
            print('State number 2 does not exist')
        
        # TransducerTypeMismatchException:
        if hfst_dev.ImplementationType.FOMA_TYPE in types:
            hfst_dev.set_default_fst_type(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE)
            tr1 = hfst_dev.regex('foo')
            tr2 = hfst_dev.regex('bar')
            tr2.convert(hfst_dev.ImplementationType.FOMA_TYPE)
            try:
                tr1.disjunct(tr2)
            except hfst_dev.exceptions.TransducerTypeMismatchException:
                print('The implementation types of transducers must be the same.')

            hfst_dev.set_default_fst_type(type)

        # fst
        # One unweighted identity path:
        if not hfst_dev.fst('foo').compare(hfst_dev.regex('{foo}')):
            raise RuntimeError('')
        # Weighted path: a tuple of string and number, e.g.
        if not hfst_dev.fst(('foo',1.4)).compare(hfst_dev.regex('{foo}::1.4')):
            raise RuntimeError('')
        if not hfst_dev.fst(('bar',-3)).compare(hfst_dev.regex('{bar}::-3')):
            raise RuntimeError('')
        if not hfst_dev.fst(('baz',0)).compare(hfst_dev.regex('{baz}')):
            raise RuntimeError('')
        # Several paths: a list or a tuple of paths and/or weighted paths, e.g.
        if not hfst_dev.fst(['foo', 'bar']).compare(hfst_dev.regex('{foo}|{bar}')):
            raise RuntimeError('')
        if not hfst_dev.fst(('foo', ('bar',5.0))).compare(hfst_dev.regex('{foo}|{bar}::5.0')):
            raise RuntimeError('')
        if not hfst_dev.fst(('foo', ('bar',5.0), 'baz', 'Foo', ('Bar',2.4))).compare(hfst_dev.regex('{foo}|{bar}::5.0|{baz}|{Foo}|{Bar}::2.4')):
            raise RuntimeError('')
        if not hfst_dev.fst([('foo',-1), ('bar',0), ('baz',3.5)]).compare(hfst_dev.regex('{foo}::-1|{bar}|{baz}::3.5')):
            raise RuntimeError('')
        # A dictionary
        if not hfst_dev.fst({'foo':'foo', 'bar':('foo',1.4), 'baz':(('foo',-1),'BAZ')}).compare(hfst_dev.regex('{foo}|{bar}:{foo}::1.4|{baz}:{foo}::-1|{baz}:{BAZ}')):
            raise RuntimeError('')
        
        # tokenized_fst
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('foo')
        tok.add_multichar_symbol('bar')
        tr = hfst_dev.tokenized_fst(tok.tokenize('foobar', 'foobaz'))
        if not tr.compare(hfst_dev.regex('[foo:foo bar:b 0:a 0:z]')):
            raise RuntimeError('')

        # HfstIterableTransducer
        # Create an empty transducer
        # The transducer has initially one start state (number zero)
        # that is not final
        fsm = hfst_dev.HfstIterableTransducer()
        # Add two states to the transducer
        fsm.add_state(1)
        fsm.add_state(2)
        # Create a transition [foo:bar] leading to state 1 with weight 0.1
        tr = hfst_dev.HfstTransition(1, 'foo', 'bar', 0.1)
        # and add it to state zero
        fsm.add_transition(0, tr)
        # Add a transition [baz:baz] with weight 0 from state 1 to state 2
        fsm.add_transition(1, hfst_dev.HfstTransition(2, 'baz', 'baz', 0.0))
        # Set state 2 as final with weight 0.3
        fsm.set_final_weight(2, 0.3)
        # Go through all states
        for state, arcs in enumerate(fsm):
            for arc in arcs:
                print('%i ' % (state), end='')
                print(arc)
            if fsm.is_final_state(state):
                print('%i %f' % (state, fsm.get_final_weight(state)) )

        for state in fsm.states():
            for arc in fsm.transitions(state):
                print('%i ' % (state), end='')
                print(arc)
            if fsm.is_final_state(state):
                print('%i %f' % (state, fsm.get_final_weight(state)) )
        
        # HfstIterableTransducer.disjunct
        lexicon = hfst_dev.HfstIterableTransducer()
        tok = hfst_dev.HfstTokenizer()
        lexicon.disjunct(tok.tokenize('dog'), 0.3)
        lexicon.disjunct(tok.tokenize('cat'), 0.5)
        lexicon.disjunct(tok.tokenize('elephant'), 1.6)
        lexicon = hfst_dev.HfstTransducer(lexicon)
        if not lexicon.compare(hfst_dev.regex('{dog}::0.3|{cat}::0.5|{elephant}::1.6')):
            raise RuntimeError('')
        
        # HfstIterableTransducer.transitions
        for state in fsm.states():
            for arc in fsm.transitions(state):
                print('%i ' % (state), end='')
                print(arc)
            if fsm.is_final_state(state):
                print('%i %f' % (state, fsm.get_final_weight(state)) )
        
        # HfstIterableTransducer.substitute and HfstTransducer.substitute
        HFST = hfst_dev.regex('a:a')
        basic = hfst_dev.HfstIterableTransducer(HFST)
        HFST.substitute('a', 'A', input=True, output=False)
        basic.substitute('a', 'A', input=True, output=False)
        
        HFST = hfst_dev.regex('a a:b b')
        basic = hfst_dev.HfstIterableTransducer(HFST)
        HFST.substitute(('a','b'),('A','B'))
        basic.substitute(('a','b'),('A','B'))
        
        HFST = hfst_dev.regex('a a:b b')
        basic = hfst_dev.HfstIterableTransducer(HFST)
        HFST.substitute(('a','b'), (('A','B'),('a','B'),('A','b')))
        basic.substitute(('a','b'), (('A','B'),('a','B'),('A','b')))
        
        HFST = hfst_dev.regex('a a:b b')
        basic = hfst_dev.HfstIterableTransducer(HFST)
        HFST.substitute(('a','b'), hfst_dev.regex('[a:b]+'))
        basic.substitute(('a','b'), hfst_dev.HfstIterableTransducer(hfst_dev.regex('[a:b]+')))
        
        HFST = hfst_dev.regex('a b c d')
        basic = hfst_dev.HfstIterableTransducer(HFST)
        HFST.substitute({'a':'A', 'b':'B', 'c':'C'})
        basic.substitute({'a':'A', 'b':'B', 'c':'C'})
        
        HFST = hfst_dev.regex('a a:b b b:c c c:d d')
        basic = hfst_dev.HfstIterableTransducer(HFST)
        HFST.substitute( {('a','a'):('A','A'), ('b','b'):('B','B'), ('c','c'):('C','C')} )
        basic.substitute( {('a','a'):('A','A'), ('b','b'):('B','B'), ('c','c'):('C','C')} )
        
        # HfstIterableTransducer.enumerate
        for state, arcs in enumerate(fsm):
            for arc in arcs:
                print('%i ' % (state), end='')
                print(arc)
            if fsm.is_final_state(state):
                print('%i %f' % (state, fsm.get_final_weight(state)) )
        
        # HfstTransducer
        # argument handling
        transducer1 = hfst_dev.regex('foo:bar baz')
        transducer2 = hfst_dev.regex('FOO:BAR BAZ')
        transducer1.reverse()
        transducer1.disjunct(transducer2)
        if not transducer2.compare(hfst_dev.regex('FOO:BAR BAZ')):
            raise RuntimeError('')
        transducer1.reverse()
        transducer1.determinize()
        transducer1.reverse()
        transducer1.determinize()
        # implementation types
        if hfst_dev.ImplementationType.FOMA_TYPE in types:
            tropical_transducer = hfst_dev.regex('foo')
            tropical_transducer.convert(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE)
            foma_transducer = hfst_dev.regex('foo')
            foma_transducer.convert(hfst_dev.ImplementationType.FOMA_TYPE)
            # TODO: segfaults
            try:
                tropical_transducer.compare(foma_transducer)
            except hfst_dev.exceptions.TransducerTypeMismatchException:
                print('Implementation types of transducers must be the same.')

        # read_att from file
        f = open('testfile2.att', 'w')
        f.write(
"""0 1 foo bar 0.3
1 0.5
--
0 0.0
--
--
0 0.0
0 0 a <eps> 0.2
""")
        f.close()

        transducers = []
        ifile = open('testfile2.att', 'r')
        try:
            while (True):
                t = hfst_dev.read_att_transducer(ifile, '<eps>')
                transducers.append(t)
                print("read one transducer")
        except hfst_dev.exceptions.NotValidAttFormatException:
            print("Error reading transducer: not valid AT&T format.")
        except hfst_dev.exceptions.EndOfStreamException:
            pass
        ifile.close()
        print("Read %i transducers in total" % len(transducers))

# read_att from string
#att_str = """0 1 a b
#1 2 c d
#2
#"""
#print(att_str)
#tr = hfst_dev.read_att(att_str, '@0@')
#print(tr)
#exit(0)

        # write_att
        tr1 = hfst_dev.regex('[foo:bar baz:0 " "]::0.3')
        tr2 = hfst_dev.empty_fst()
        tr3 = hfst_dev.epsilon_fst(0.5)
        tr4 = hfst_dev.regex('[foo]')
        tr5 = hfst_dev.empty_fst()

        f = open('testfile3.att', 'w')
        for tr in [tr1, tr2, tr3, tr4]:
            tr.write_att(f)
            f.write('--\n')
        tr5.write_att(f)
        f.close()

        # extract_paths
        tr = hfst_dev.regex('a:b+ (a:c+)')
        print(tr)
        print(tr.extract_paths(max_cycles=1, output='text'))
        print(tr.extract_paths(max_number=4, output='text'))
        print(tr.extract_paths(max_cycles=1, max_number=4, output='text'))

        # HfstOutputStream
        res = ['foo:bar','0','0 - 0','"?":?','a* b+']
        ostr = hfst_dev.HfstOutputStream(filename='testfile1.hfst')
        for re in res:
            ostr.write(hfst_dev.regex(re))
            ostr.flush()
        ostr.close()
        
        # HfstInputStream
        istr = hfst_dev.HfstInputStream('testfile1.hfst')
        transducers = []
        while not (istr.is_eof()):
            transducers.append(istr.read())
        istr.close()
        if not len(transducers) == len(res):
            raise RuntimeError('')
        i=0
        for tr in transducers:
            if not tr.compare(hfst_dev.regex(res[i])):
                raise RuntimeError('')
            i+=1

# push_weights

# QuickStart (1/3)

        tr1 = hfst_dev.regex('foo:bar')
        tr2 = hfst_dev.regex('bar:baz')
        tr1.compose(tr2)
        print(tr1)

# QuickStart (2/3)

# Create as HFST basic transducer [a:b] with transition weight 0.3 and final weight 0.5.
        t = hfst_dev.HfstIterableTransducer()
        t.add_state(1)
        t.add_transition(0, 1, 'a', 'b', 0.3)
        t.set_final_weight(1, 0.5)

# Convert to tropical OpenFst format (the default, if not set) and push weights toward final state.
        T = hfst_dev.HfstTransducer(t)
        T.push_weights_to_end()

# Convert back to HFST basic transducer.
        tc = hfst_dev.HfstIterableTransducer(T)
        try:
        # Rounding might affect the precision.
            if (0.79 < tc.get_final_weight(1)) and (tc.get_final_weight(1) < 0.81):
                print("TEST PASSED")
            else:
                if hfst_dev.get_default_fst_type() == hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE:
                    raise RuntimeError('')
                else:
                    pass # ok to fail if weights are not in use
        # If the state does not exist or is not final
        except hfst_dev.exceptions.HfstException:
            print("TEST FAILED: An exception thrown.")
            raise RuntimeError('')

# QuickStart (3/3)

# Create a simple lexicon transducer [[foo bar foo] | [foo bar baz]].
        tok = hfst_dev.HfstTokenizer()
        tok.add_multichar_symbol('foo')
        tok.add_multichar_symbol('bar')
        tok.add_multichar_symbol('baz')
        
        words = hfst_dev.tokenized_fst(tok.tokenize('foobarfoo'))
        t = hfst_dev.tokenized_fst(tok.tokenize('foobarbaz'))
        words.disjunct(t)

# Create a rule transducer that optionally replaces 'bar' with 'baz' between 'foo' and 'foo'.
        rule = hfst_dev.regex('bar (->) baz || foo _ foo')

# Apply the rule transducer to the lexicon.
        words.compose(rule)
        words.minimize()

# Extract all string pairs from the result and print them to standard output.
        results = 0
        try:
            # Extract paths and remove tokenization
            results = words.extract_paths(output='dict')
        except hfst_dev.exceptions.TransducerIsCyclicException:
            # This should not happen because transducer is not cyclic.
            print("TEST FAILED")
            exit(1)

        for input,outputs in results.items():
            print('%s:' % input)
            for output in outputs:
                print('  %s\t%f' % (output[0], output[1]))


# Foma issue

