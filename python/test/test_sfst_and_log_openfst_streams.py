# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

# Check that sfst binary format can be read and written even if sfst is disabled
# and log openfst format can be read even if log openfst is disabled.

if not hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.SFST_TYPE):

    # write in sfst binary format
    tr = hfst_dev.regex('foo:bar baz foo:bar baz')
    ostr = hfst_dev.HfstOutputStream(filename='expression.sfst.hfst', hfst_format=False, type=hfst_dev.ImplementationType.SFST_TYPE)
    ostr.write(tr)
    ostr.close()

    # read sfst binary format (the file that was just written with HFST tools)
    istr = hfst_dev.HfstInputStream('expression.sfst.hfst')
    TR = istr.read_all()
    istr.close()
    assert len(TR) == 1
    assert(tr.compare(TR[0]))

    # TODO: read sfst binary format (native SFST file - multicharacter symbols must be enclosed in square brackets...)
    #import os.path
    #if os.path.isfile('expression.sfst'):
    #    istr = hfst_dev.HfstInputStream('expression.sfst')
    #    TR = istr.read_all()
    #    istr.close()
    #    assert len(TR) == 1
    #    assert(tr.compare(TR[0]))

if not hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.LOG_OPENFST_TYPE):

    import os.path
    if os.path.isfile('expression.ofstlog.hfst'):
        # read openfst log binary format (written with HFST tools)
        istr = hfst_dev.HfstInputStream('expression.ofstlog.hfst')
        TR = istr.read_all()
        istr.close()
        assert len(TR) == 1
        assert(tr.compare(TR[0]))
