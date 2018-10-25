# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst

# Check that sfst binary format can be read and written even if sfst is disabled
# and log openfst format can be read even if log openfst is disabled.

if not hfst.HfstTransducer.is_implementation_type_available(hfst.ImplementationType.SFST_TYPE):

    # write in sfst binary format
    tr = hfst.regex('foo:bar baz foo:bar baz')
    ostr = hfst.HfstOutputStream(filename='expression.sfst.hfst', hfst_format=False, type=hfst.ImplementationType.SFST_TYPE)
    ostr.write(tr)
    ostr.close()

    # read sfst binary format (the file that was just written with HFST tools)
    istr = hfst.HfstInputStream('expression.sfst.hfst')
    TR = istr.read_all()
    istr.close()
    assert len(TR) == 1
    assert(tr.compare(TR[0]))

    # TODO: read sfst binary format (native SFST file - multicharacter symbols must be enclosed in square brackets...)
    #import os.path
    #if os.path.isfile('expression.sfst'):
    #    istr = hfst.HfstInputStream('expression.sfst')
    #    TR = istr.read_all()
    #    istr.close()
    #    assert len(TR) == 1
    #    assert(tr.compare(TR[0]))

if not hfst.HfstTransducer.is_implementation_type_available(hfst.ImplementationType.LOG_OPENFST_TYPE):

    import os.path
    if os.path.isfile('expression.ofstlog.hfst'):
        # read openfst log binary format (written with HFST tools)
        istr = hfst.HfstInputStream('expression.ofstlog.hfst')
        TR = istr.read_all()
        istr.close()
        assert len(TR) == 1
        assert(tr.compare(TR[0]))
