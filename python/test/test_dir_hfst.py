# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

diritems = \
['EPSILON',
 'HfstIterableTransducer', 'HfstTransition', 'HfstInputStream', 'HfstOutputStream',
 'HfstTokenizer', 'HfstTransducer', 'IDENTITY', 'LexcCompiler', 'PmatchContainer',
 'UNKNOWN',
 'XfstCompiler', 'XreCompiler', 'compile_lexc_file',
 'compile_pmatch_expression', 'compile_pmatch_file', 'compile_xfst_file', 'concatenate', 'disjunct',
 'empty_fst', 'epsilon_fst', 'exceptions', 'fsa', 'fst', 'fst_type_to_string', 'get_default_fst_type',
 'intersect', 'is_diacritic',
 'read_att_input', 'read_att_string', 'regex', 'sfst_rules', 'xerox_rules', 'set_default_fst_type',
 'start_xfst', 'tokenized_fst']

dirhfst = dir(hfst_dev)

for item in diritems:
    if not item in dirhfst:
        print('error: dir(hfst_dev) does not contain', item)
        assert(False)

assert hfst_dev.EPSILON == '@_EPSILON_SYMBOL_@'
assert hfst_dev.UNKNOWN == '@_UNKNOWN_SYMBOL_@'
assert hfst_dev.IDENTITY == '@_IDENTITY_SYMBOL_@'

assert hfst_dev.ImplementationType.SFST_TYPE == 0
assert hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE == 1
assert hfst_dev.ImplementationType.LOG_OPENFST_TYPE == 2
assert hfst_dev.ImplementationType.FOMA_TYPE == 3
assert hfst_dev.ImplementationType.XFSM_TYPE == 4
assert hfst_dev.ImplementationType.HFST_OL_TYPE == 5
assert hfst_dev.ImplementationType.HFST_OLW_TYPE == 6
assert hfst_dev.ImplementationType.HFST2_TYPE == 7
assert hfst_dev.ImplementationType.UNSPECIFIED_TYPE == 8
assert hfst_dev.ImplementationType.ERROR_TYPE == 9
