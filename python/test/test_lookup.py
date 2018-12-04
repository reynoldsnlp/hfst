# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

for type in [hfst_dev.ImplementationType.SFST_TYPE, hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE, hfst_dev.ImplementationType.FOMA_TYPE]:
    if hfst_dev.HfstTransducer.is_implementation_type_available(type):
        
        hfst_dev.set_default_fst_type(type)
        tr = hfst_dev.regex('[foo:bar] | [?:B ?:A ?:R]')
        result = tr.lookup('foo')
        assert(len(result) == 1)
        assert(result[0][0] == 'bar')
        tr = hfst_dev.regex('[f:0 o:0 o:foo]')
        result = tr.lookup('foo')
        assert(len(result) == 1)
        assert(result[0][0] == 'foo')
        tr = hfst_dev.regex('[foo:bar]|[f:B o:A o:R]')
        result = tr.lookup('foo')
        assert(len(result) == 1)
        assert(result[0][0] == 'bar')
