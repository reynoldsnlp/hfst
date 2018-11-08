# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

for type in [hfst_dev.ImplementationType.SFST_TYPE, hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE, hfst_dev.ImplementationType.FOMA_TYPE]:
    if hfst_dev.HfstTransducer.is_implementation_type_available(type):
        
        f = open('cats_and_dogs.prolog', 'r')
        F = open('tmp', 'w')
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('{cat}')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        F.write('\n')
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('0 - 0')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        F.write('\n')
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('{dog}:{cat}::0.5')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        F.write('\n')
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('[c a:h t:a 0:t]::-1.5')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        
        try:
            tr = hfst_dev.read_prolog_transducer(f)
            assert(False)
        except hfst_dev.exceptions.EndOfStreamException as e:
            pass
        
        f.close()
        F.close()
        
        f = open('tmp', 'r')
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('{cat}')
        assert(tr.compare(re))
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('0 - 0')
        assert(tr.compare(re))
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('{dog}:{cat}::0.5')
        assert(tr.compare(re))
        
        tr = hfst_dev.read_prolog_transducer(f)
        re = hfst_dev.regex('[c a:h t:a 0:t]::-1.5')
        
        try:
            tr = hfst_dev.read_prolog_transducer(f)
            assert(False)
        except hfst_dev.exceptions.EndOfStreamException as e:
            pass
        
        f.close()
