import hfst, sys
import hfst_commandline

silent=False
harmonize=True
eliminate_flags=False
retval=0

short_getopts='sqHe'
long_getopts=['silent','quiet','do-not-harmonize','eliminate-flags']
options = hfst_commandline.hfst_getopt(short_getopts, long_getopts, 2)

# todo: handle this to hfst_commandline...
# raise RuntimeError('Usage: hfst-compare.py INFILE1 INFILE2')
    
#for arg in argv[1:]:
for opt in options[0]:
    if opt[0] == '-s' or opt[0] == '--silent' or opt[0] == '-q' or opt[0] == '--quiet':
        silent = True
    elif opt[0] == '-H' or opt[0] == '--do-not-harmonize':
        harmonize = False
    elif opt[0] == '-e' or opt[0] == '--eliminate-flags':
        eliminate_flags=True
    #elif opt[0] == '-1':
    #    explicit_ifile1 = opt[1] 
    #elif opt[0] == '-2':
    #    explicit_ifile2 = opt[1]
    else:
        pass # unknown options were already checked in hfst_getopt

streams = hfst_commandline.get_two_hfst_input_streams(options)
istr1 = streams[0]
istr2 = streams[1]

if (istr1.get_type() != istr2.get_type()):
    raise RuntimeError('Error: transducer types differ in ' + argv[1] + ' and ' + argv[2])

while((not istr1.is_eof()) and (not istr2.is_eof())):
    tr1 = istr1.read()
    tr2 = istr2.read()
    if eliminate_flags:
        tr1.eliminate_flags()
        tr2.eliminate_flags()
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
