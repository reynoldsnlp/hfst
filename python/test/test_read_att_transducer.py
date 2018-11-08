# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev

for type in [hfst_dev.ImplementationType.SFST_TYPE, hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE, hfst_dev.ImplementationType.FOMA_TYPE]:
    if hfst_dev.HfstTransducer.is_implementation_type_available(type):

        transducers = []
        ifile = open('testfile.att', 'r')
        try:
            while (True):
                t = hfst_dev.read_att_transducer(ifile, '<eps>')
                transducers.append(t)
        except hfst_dev.exceptions.NotValidAttFormatException as e:
            print("Error reading transducer: not valid AT&T format.")
        except hfst_dev.exceptions.EndOfStreamException as e:
            pass
        ifile.close()
        assert(len(transducers) == 4)

