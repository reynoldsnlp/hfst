"""

Python bindings for HFST finite-state transducer library written in C++.

CLASSES

    class AttReader(builtins.object)
    class HfstInputStream(builtins.object)
    class HfstIterableTransducer(builtins.object)
    class HfstOutputStream(builtins.object)
    class HfstTokenizer(builtins.object)
    class HfstTransducer(builtins.object)
    class HfstTransition(builtins.object)
    class ImplementationType(builtins.object)
    class LexcCompiler(builtins.object)
    class Location(builtins.object)
    class PmatchContainer(builtins.object)
    class PrologReader(builtins.object)
    class TwolcCompiler(builtins.object)
    class XfstCompiler(builtins.object)
    class XreCompiler(builtins.object)

FUNCTIONS

    compile_lexc_file(filename, **kwargs)
    compile_lexc_files(filenames, **kwargs)
    compile_lexc_script(script, **kwargs)
    compile_pmatch_expression(pmatch)
    compile_pmatch_file(filename)
    compile_sfst_file(filename, **kwargs)
    compile_twolc_file(filename, **kwargs)
    compile_twolc_script(script, **kwargs)
    compile_xfst_file(filename, **kwargs)
    compile_xfst_script(script, **kwargs)
    compose(transducers)
    concatenate(transducers)
    cross_product(transducers)
    disjunct(transducers)
    empty_fst()
    epsilon_fst(weight=0)
    fsa(arg)
    fsa_to_fst(fsa, separator='')
    fst(arg)
    fst_to_fsa(fst, separator='')
    fst_type_to_string(t)
    get_default_fst_type()
    intersect(transducers)
    is_diacritic(symbol)
    is_epsilon(...)
    read_att_input()
    read_att_string(att)
    read_att_transducer(f, epsilonstr='@_EPSILON_SYMBOL_@', linecount=[0])
    read_prolog_transducer(f, linecount=[0])
    regex(re, **kwargs)
    set_default_fst_type(t)
    start_xfst(**kwargs)
    subtract(transducers)
    tokenized_fst(arg, weight=0)

DATA

    EPSILON = '@_EPSILON_SYMBOL_@'
    IDENTITY = '@_IDENTITY_SYMBOL_@'
    UNKNOWN = '@_UNKNOWN_SYMBOL_@'

"""

import hfst_dev.exceptions
import hfst_dev.sfst_rules
import hfst_dev.xerox_rules
from libhfst_dev import \
    compile_lexc_file, \
    compile_lexc_files, \
    compile_lexc_script, \
    compile_pmatch_expression, \
    compile_pmatch_file, \
    compile_sfst_file, \
    compile_twolc_file, \
    compile_twolc_script, \
    compile_xfst_file, \
    compile_xfst_script, \
    compose, \
    concatenate, \
    cross_product, \
    disjunct, \
    empty_fst, \
    epsilon_fst, \
    fsa, \
    fsa_to_fst, \
    fst, \
    fst_to_fsa, \
    fst_type_to_string, \
    get_default_fst_type, \
    intersect, \
    is_diacritic, \
    is_epsilon, \
    read_att_input, \
    read_att_string, \
    read_att_transducer, \
    read_prolog_transducer, \
    regex, \
    set_default_fst_type, \
    start_xfst, \
    subtract, \
    tokenized_fst, \
    AttReader, \
    HfstInputStream, \
    HfstIterableTransducer, \
    HfstOutputStream, \
    HfstTokenizer, \
    HfstTransducer, \
    HfstTransition, \
    ImplementationType, \
    LexcCompiler, \
    Location, \
    PmatchContainer, \
    PrologReader, \
    TwolcCompiler, \
    XfstCompiler, \
    XreCompiler, \
    EPSILON, \
    IDENTITY, \
    UNKNOWN

__version__="3.15.0.10"
