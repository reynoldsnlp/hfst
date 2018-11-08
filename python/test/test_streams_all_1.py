# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 2:
    sys.path.insert(0, sys.argv[2])
import hfst_dev
if len(sys.argv) < 1:
    raise RuntimeError('Transducer format must be given as first argument')

if sys.argv[1] == 'sfst':
    if not hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.SFST_TYPE):
        sys.exit(77)
    hfst_dev.set_default_fst_type(hfst_dev.ImplementationType.SFST_TYPE)
elif sys.argv[1] == 'foma':
    if not hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.FOMA_TYPE):
        sys.exit(77)
    hfst_dev.set_default_fst_type(hfst_dev.ImplementationType.FOMA_TYPE)
elif sys.argv[1] == 'openfst':
    if not hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE):
        sys.exit(77)
    hfst_dev.set_default_fst_type(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE)
else:
    raise RuntimeError('implementation format not recognized')

tr1 = hfst_dev.regex('föö:bär')
tr2 = hfst_dev.regex('0')
tr3 = hfst_dev.regex('0-0')
trs = [tr1, tr2, tr3]

ostr = hfst_dev.HfstOutputStream()
ostr.write(trs)
ostr.flush()
ostr.close()
