# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

for type in [hfst_dev.ImplementationType.SFST_TYPE, hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE, hfst_dev.ImplementationType.FOMA_TYPE]:
    if hfst_dev.HfstTransducer.is_implementation_type_available(type):

        comp = hfst_dev.XreCompiler(hfst_dev.get_default_fst_type())
        comp.set_expand_definitions(True)
        comp.define_xre('FooStar', '[foo]*')
        tr = hfst_dev.regex('[foo]+')
        comp.define_transducer('FooPlus', tr)
        comp.define_xre('Bar', 'bar')
        comp.undefine('Bar')
        
        TR = comp.compile('FooStar a FooPlus Bar')
        TR1 = hfst_dev.regex('[foo* a foo+ Bar]')
        assert TR1.compare(TR)

        tr = hfst_dev.regex('foo:bar')
        comp.define_transducer('FooBar', tr)
        TR = comp.compile('FooBar.l')
        TR1 = hfst_dev.regex('bar')
        assert TR1.compare(TR)
