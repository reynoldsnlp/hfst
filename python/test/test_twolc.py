# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

for n in [1, 2, 3]:
    assert(len(hfst_dev.compile_twolc_file('test'+str(n)+'.twolc')) == 1)

if hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.FOMA_TYPE):
    for n in [1, 2, 3]:
        assert(len(hfst_dev.compile_twolc_file('test'+str(n)+'.twolc', verbose=True, type=hfst_dev.ImplementationType.FOMA_TYPE)) == 1)
