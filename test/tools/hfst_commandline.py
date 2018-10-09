import hfst

from sys import argv

def check_option(opt, long_opts, short_opts):
    if (not opt in long_opts) and (not opt in short_opts):
        raise RuntimeError('argument not recognized: ' + opt)

def handle_implementation_type(opt):
    global impl
    arg = opt[0]
    if arg == '-f' or arg == '--format':
        val = opt[1]
        if val == 'sfst':
            impl = hfst.ImplementationType.SFST_TYPE
        elif val == 'openfst-tropical':
            impl = hfst.ImplementationType.TROPICAL_OPENFST_TYPE
        elif val == 'foma':
            impl = hfst.ImplementationType.FOMA_TYPE
        else:
            raise RuntimeError('type not recognized: ' + val)

def hfst_getopt(short_opts, short_getopts, long_opts, long_getopts):
    import getopt
    global argv
    short_and_long_opts = getopt.gnu_getopt(argv[1:], short_getopts, long_getopts)
    for opts in short_and_long_opts:
        for opt in opts:
            check_option(opt[0], short_opts, long_opts)
            handle_implementation_type(opt)

impl = hfst.ImplementationType.TROPICAL_OPENFST_TYPE
