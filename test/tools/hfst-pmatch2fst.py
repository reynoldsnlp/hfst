from sys import argv
if len(argv) != 2:
    raise RuntimeError('Usage: hfst-pmatch2fst.py INFILE')
infilename = argv[1]
import hfst
defs = hfst.compile_pmatch_file(infilename)
ostr = hfst.HfstOutputStream(type=hfst.ImplementationType.HFST_OLW_TYPE)
for tr in defs:
    ostr.write(tr)
ostr.close()
