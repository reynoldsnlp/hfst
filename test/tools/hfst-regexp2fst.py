import hfst
from sys import argv, stdin, stderr
impl=hfst.ImplementationType.TROPICAL_OPENFST_TYPE
skip_next = False
harmonize=True
semicolons=False
infile=stdin

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
    elif arg == '-H' or arg == '--do-not-harmonize':
        harmonize=False
    elif arg == '-S' or arg == '--semicolon':
        semicolons=True
    else:
        infile = open(arg, 'r')

ostr = hfst.HfstOutputStream(type=impl)
comp = hfst.XreCompiler(impl)
comp.set_harmonization(harmonize)
if (semicolons):
    data = infile.read().rstrip() # todo: trailing whitespace should be taken care of by compile function
    chars_read = [0]
    while(chars_read[0] < len(data)):
        stderr.write("compiling data: '" + data[chars_read[0]:] + "'\n")
        tr = comp.compile(data, chars_read)
        if tr != None:
            ostr.write(tr)
else:
    for line in infile:
        stderr.write(line)
        tr = comp.compile(line)
        if tr != None:
            ostr.write(tr)

ostr.close()
if infile != stdin:
    infile.close()
