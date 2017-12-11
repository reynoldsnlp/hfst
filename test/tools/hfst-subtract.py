import hfst
ifile1=None
ifile2=None
from sys import argv
if len(argv) < 3 or len(argv) > 5:
    raise RuntimeError('Usage: hfst-subtract.py INFILE1 INFILE2')
for arg in argv[1:]:
    if arg == '-1':
        ifile1 = '<next>'
    elif arg == '-2':
        ifile2 = '<next>'
    elif ifile1 == '<next>':
        ifile1 = arg
    elif ifile2 == '<next>':
        ifile2 = arg
    elif ifile1 == None:
        ifile1 = arg
    elif ifile2 == None:
        ifile2 = arg
    else:
        raise RuntimeError('Usage: hfst-subtract.py INFILE1 INFILE2')

istr1 = hfst.HfstInputStream(ifile1)
istr2 = hfst.HfstInputStream(ifile2)
if (istr1.get_type() != istr2.get_type()):
    raise RuntimeError('Error: transducer types differ in ' + argv[1] + ' and ' + argv[2])
ostr = hfst.HfstOutputStream(type=istr1.get_type())

while((not istr1.is_eof()) and (not istr2.is_eof())):
    tr1 = istr1.read()
    tr2 = istr2.read()
    tr1.subtract(tr2)
    tr1.write(ostr)
    ostr.flush()

istr1.close()
istr2.close()
