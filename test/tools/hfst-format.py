import hfst
list_formats=False
test_format=None
from sys import argv
for arg in argv[1:]:
    if arg == '--list-formats':
        list_formats=True
    elif arg == '--test-format':
        test_format='<next>'
    elif test_format == '<next>':
        test_format = arg
    else:
        raise RuntimeError('error: hfst-format.py: option not recognized: ' + arg)
if (not list_formats) and test_format == None:
    raise RuntimeError('error: hfst-format.py: option --list-formats or --test-format FMT must be given')

aval = hfst.HfstTransducer.is_implementation_type_available

if list_formats:
    print('Backend                         Names recognized')
    print('')
    if aval(hfst.ImplementationType.SFST_TYPE):
        print('SFST                            sfst')
    if aval(hfst.ImplementationType.TROPICAL_OPENFST_TYPE):
        print('OpenFst (tropical weights)      openfst-tropical, openfst, ofst, ofst-tropical')
    if aval(hfst.ImplementationType.LOG_OPENFST_TYPE):
        print('OpenFst (logarithmic weights)   openfst-log, ofst-log')
    if aval(hfst.ImplementationType.FOMA_TYPE):
        print('foma                            foma')
    if aval(hfst.ImplementationType.HFST_OL_TYPE):
        print('Optimized lookup (weighted)     optimized-lookup-unweighted, olu')
    if aval(hfst.ImplementationType.HFST_OLW_TYPE):
        print('Optimized lookup (unweighted)   optimized-lookup-weighted, olw, optimized-lookup, ol')

if test_format != None:
    if test_format == 'sfst':
        if aval(hfst.ImplementationType.SFST_TYPE):
            sys.exit(0)
        else:
            sys.exit(1)
    elif test_format == 'openfst-tropical' or test_format == 'openfst' or test_format == 'ofst' or test_format == 'ofst-tropical':
        if aval(hfst.ImplementationType.TROPICAL_OPENFST_TYPE):
            sys.exit(0)
        else:
            sys.exit(1)
    elif test_format == 'openfst-log' or test_format == 'ofst-log':
        if aval(hfst.ImplementationType.LOG_OPENFST_TYPE):
            sys.exit(0)
        else:
            sys.exit(1)
    elif test_format == 'foma':
        if aval(hfst.ImplementationType.FOMA_TYPE):
            sys.exit(0)
        else:
            sys.exit(1)
    elif test_format == 'optimized-lookup-unweighted' or test_format == 'olu':
        if aval(hfst.ImplementationType.HFST_OL_TYPE):
            sys.exit(0)
        else:
            sys.exit(1)
    elif test_format == 'optimized-lookup-weighted' or test_format == 'olw' or test_format == 'optimized-lookup' or test_format == 'ol':
        if aval(hfst.ImplementationType.HFST_OLW_TYPE):
            sys.exit(0)
        else:
            sys.exit(1)
    else:
        raise RuntimeError('hfst-format.py: format ' + test_format + ' not recognized')
