import hfst
from sys import argv, stdin

inputfilename=None
outputfilename=None
has_spaces=False
pairstrings=False
impl=hfst.ImplementationType.TROPICAL_OPENFST_TYPE

skip_next = False
for i in range(1, len(argv)):
    if skip_next:
        skip_next = False
        continue
    arg = argv[i]
    if arg == '-f' or arg == '--format':
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
    elif arg == '-i':
        skip_next= True
        inputfilename = argv[i+1]
    elif arg == '-o':
        skip_next= True
        outputfilename = argv[i+1]
    elif arg == '-S' or arg == '--has-spaces':
        has_spaces=True
    elif arg == '-p' or arg == '--pairstrings':
        pairstrings=True
    elif inputfilename == None:
        inputfilename = arg
    elif outputfilename == None:
        outputfilename = arg
    else:
        raise RuntimeError('Unknown option: ' + arg)

hfst.set_default_fst_type(impl)

istr = None
if inputfilename != None:
    istr = open(inputfilename, 'r')
else:
    istr = stdin

ostr = None
if outputfilename != None:
    ostr = hfst.HfstOutputStream(filename=outputfilename, type=impl)
else:
    ostr = hfst.HfstOutputStream(type=impl)

for line in istr:
    line = line.rstrip()
    print(line)
    #ostr.write(TR)
    #ostr.flush()

if inputfilename != None:
    istr.close()
ostr.close()
