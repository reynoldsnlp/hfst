from sys import argv
from hfst import ImplementationType, HfstInputStream

# check if option opt is listed in short_getopts or long_getopts
# '-' chars are stripped from the beginning of opt before comparing
# ':' chars in short_getopts and '=' chars in long_getopts are ignored
def _check_option(opt, short_getopts, long_getopts):
    opt_ = opt.lstrip('-')
    if (len(opt_) == 1 and opt_ in short_getopts):
        return
    for longopt in long_getopts:
        if opt_ in longopt:
            return
    raise RuntimeError('argument not recognized: ' + opt)

def get_implementation_type(val):
    if val == 'sfst':
        return ImplementationType.SFST_TYPE
    elif val == 'openfst-tropical':
        return ImplementationType.TROPICAL_OPENFST_TYPE
    elif val == 'foma':
        return ImplementationType.FOMA_TYPE
    else:
        raise RuntimeError('type not recognized: ' + val)

# check command line parameters:
# - that any optional arguments are allowed (given as --foo FOO or --foo=FOO)
# - that parameters are listed in short_getopts or long_getopts
# - that number of free parameters is not bigger than free_params
def hfst_getopt(short_getopts, long_getopts, free_params=0):
    import getopt
    global argv
    options = getopt.gnu_getopt(argv[1:], short_getopts, long_getopts)
    for opt in options[0]:
        _check_option(opt[0], short_getopts, long_getopts)
    if len(options) == 2:
        if len(options[1]) > free_params:
            raise RuntimeError('too many free parameters given (' + str(len(options[1])) + '), maximum is ' + str(free_params))
    return options

def _get_input_stream(filename):
    if filename == '-':
        return HfstInputStream()
    elif filename != None:
        return HfstInputStream(filename)
    else:
        return None

def get_two_hfst_input_streams(options):
    explicit_ifile1=None
    explicit_ifile2=None
    arg1=None
    arg2=None
    for opt in options[0]:
        if opt[0] == '-1':
            explicit_ifile1 = opt[1] 
        elif opt[0] == '-2':
            explicit_ifile2 = opt[1]
        else:
            pass        
    # free arguments were given
    if len(options) == 2:
        # at least one
        if len(options[1]) >= 1:
            arg1 = options[1][0]
            # and a second one
        if len(options[1]) == 2:
            arg2 = options[1][1]
    istr1 = None
    istr2 = None
    istr1 = _get_input_stream(explicit_ifile1)
    istr2 = _get_input_stream(explicit_ifile2)
    if istr1 != None and istr2 != None:
        pass
    elif istr1 == None and istr2 != None:
        if arg1 == None:
            arg1 = '-'
        istr1 = _get_input_stream(arg1)
    elif istr1 != None and istr2 == None:
        if arg1 == None:
            arg1 = '-'
        istr2 = _get_input_stream(arg1)
    else:
        if arg2 == None:
            istr1 = _get_input_stream('-')
            istr2 = _get_input_stream(arg1)
        else:
            istr1 = _get_input_stream(arg1)
            istr2 = _get_input_stream(arg2)
    return (istr1, istr2)
