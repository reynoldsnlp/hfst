import hfst
import sys

for type in [hfst.types.SFST_TYPE, hfst.types.TROPICAL_OPENFST_TYPE, hfst.types.FOMA_TYPE]:
    if hfst.HfstTransducer.is_implementation_type_available(type):
        
        f = open('cats_and_dogs.prolog', 'r')
        F = open('tmp', 'w')
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('{cat}')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        F.write('\n')
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('0 - 0')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        F.write('\n')
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('{dog}:{cat}::0.5')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        F.write('\n')
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('[c a:h t:a 0:t]::-1.5')
        assert(tr.compare(re))
        tr.write_prolog(F, True)
        
        try:
            tr = hfst.read_prolog_transducer(f)
            assert(False)
        except hfst.exceptions.EndOfStreamException as e:
            pass
        
        f.close()
        F.close()
        
        f = open('tmp', 'r')
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('{cat}')
        assert(tr.compare(re))
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('0 - 0')
        assert(tr.compare(re))
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('{dog}:{cat}::0.5')
        assert(tr.compare(re))
        
        tr = hfst.read_prolog_transducer(f)
        re = hfst.regex('[c a:h t:a 0:t]::-1.5')
        
        try:
            tr = hfst.read_prolog_transducer(f)
            assert(False)
        except hfst.exceptions.EndOfStreamException as e:
            pass
        
        f.close()