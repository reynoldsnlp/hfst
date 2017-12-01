import hfst, sys

in1=None 
in2=None
silent=False
harmonize=True
retval=0
from sys import argv
if len(argv) < 3:
    raise RuntimeError('Usage: hfst-compose.py INFILE1 INFILE2')
for arg in argv[1:]:
    if arg == '-s' or arg == '--silent' or arg == '-q' or arg == '--quiet':
        silent = True
    elif arg == '-H' or arg == '--do-not-harmonize':
        harmonize = False
    else:
        if in1 == None:
            in1 = arg
        else:
            in2 = arg
            
istr1 = hfst.HfstInputStream(in1)
istr2 = hfst.HfstInputStream(in2)
if (istr1.get_type() != istr2.get_type()):
    raise RuntimeError('Error: transducer types differ in ' + in1 + ' and ' + in2)

while((not istr1.is_eof()) and (not istr2.is_eof())):
    tr1 = istr1.read()
    tr2 = istr2.read()
    if (tr1.compare(tr2, harmonize)):
        if not silent:
            print(tr1.get_name() + ' == ' + tr2.get_name())
    else:
        if not silent:
            print(tr1.get_name() + ' != ' + tr2.get_name())
        retval=1

istr1.close()
istr2.close()
sys.exit(retval)
