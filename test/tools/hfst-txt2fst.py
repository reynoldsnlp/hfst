import hfst
from sys import argv, stdin
epsilonstr=hfst.EPSILON
inputfilename=None
impl=hfst.ImplementationType.TROPICAL_OPENFST_TYPE
skip_next = False
for i in range(1, len(argv)):
    if skip_next:
        skip_next = False
        continue
    arg = argv[i]
    if arg == '-f':
        skip_next= True
        val = argv[i+1]
        if val == 'sfst':
            impl = hfst.ImplementationType.SFST_TYPE
        elif val == 'openfst-tropical':
            impl = hfst.ImplementationType.TROPICAL_OPENFST_TYPE
        elif val == 'foma':
            impl = hfst.ImplementationType.FOMA_TYPE
        else:
            raise RuntimeError('type not recognized: ' + val)
    elif arg == '-e':
        skip_next= True
        epsilonstr = argv[i+1]
    elif arg == '-i':
        skip_next= True
        inputfilename = argv[i+1]
    else:
        raise RuntimeError('argument not recognized: ' + arg)

istr = None
if inputfilename != None:
    istr = open(inputfilename, 'r')
else:
    istr = stdin
ostr = hfst.HfstOutputStream()

att = hfst.AttReader(istr, epsilonstr)

for tr in att:
    ostr.write(tr)
    ostr.flush()

if inputfilename != None:
    istr.close()
ostr.close()
