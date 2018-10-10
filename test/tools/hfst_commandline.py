import hfst

from sys import argv

# check if option opt is listed in short_getopts or long_getopts
# '-' chars are stripped from the beginning of opt before comparing
# ':' chars in short_getopts and '=' chars in long_getopts are ignored
def check_option(opt, short_getopts, long_getopts):
    opt_ = opt.lstrip('-')
    if (len(opt_) == 1 and opt_ in short_getopts):
        return
    for longopt in long_getopts:
        if opt_ in longopt:
            return
    raise RuntimeError('argument not recognized: ' + opt)

def get_implementation_type(val):
    if val == 'sfst':
        return hfst.ImplementationType.SFST_TYPE
    elif val == 'openfst-tropical':
        return hfst.ImplementationType.TROPICAL_OPENFST_TYPE
    elif val == 'foma':
        return hfst.ImplementationType.FOMA_TYPE
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
        check_option(opt[0], short_getopts, long_getopts)
    if len(options) == 2:
        if len(options[1]) > free_params:
            raise RuntimeError('too many free parameters given (' + str(len(options[1])) + '), maximum is ' + str(free_params))
    return options
