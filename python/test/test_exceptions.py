# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev.exceptions

# HfstException and its subclasses

e = hfst_dev.exceptions.HfstException()
e = hfst_dev.exceptions.HfstException('foo','bar', 10)
e = hfst_dev.exceptions.HfstTransducerTypeMismatchException('foo','bar', 10)
e = hfst_dev.exceptions.ImplementationTypeNotAvailableException('foo','bar', 10, 1)
e = hfst_dev.exceptions.FunctionNotImplementedException('foo','bar', 10)
e = hfst_dev.exceptions.StreamNotReadableException('foo','bar', 10)
e = hfst_dev.exceptions.StreamCannotBeWrittenException('foo','bar', 10)
e = hfst_dev.exceptions.StreamIsClosedException('foo','bar', 10)
e = hfst_dev.exceptions.EndOfStreamException('foo','bar', 10)
e = hfst_dev.exceptions.TransducerIsCyclicException('foo','bar', 10)
e = hfst_dev.exceptions.NotTransducerStreamException('foo','bar', 10)
e = hfst_dev.exceptions.NotValidAttFormatException('foo','bar', 10)
e = hfst_dev.exceptions.NotValidPrologFormatException('foo','bar', 10)
e = hfst_dev.exceptions.NotValidLexcFormatException('foo','bar', 10)
e = hfst_dev.exceptions.StateIsNotFinalException('foo','bar', 10)
e = hfst_dev.exceptions.ContextTransducersAreNotAutomataException('foo','bar', 10)
e = hfst_dev.exceptions.TransducersAreNotAutomataException('foo','bar', 10)
e = hfst_dev.exceptions.StateIndexOutOfBoundsException('foo','bar', 10)
e = hfst_dev.exceptions.TransducerHeaderException('foo','bar', 10)
e = hfst_dev.exceptions.MissingOpenFstInputSymbolTableException('foo','bar', 10)
e = hfst_dev.exceptions.TransducerTypeMismatchException('foo','bar', 10)
e = hfst_dev.exceptions.EmptySetOfContextsException('foo','bar', 10)
e = hfst_dev.exceptions.SpecifiedTypeRequiredException('foo','bar', 10)
e = hfst_dev.exceptions.HfstFatalException('foo','bar', 10)
e = hfst_dev.exceptions.TransducerHasWrongTypeException('foo','bar', 10)
e = hfst_dev.exceptions.IncorrectUtf8CodingException('foo','bar', 10)
e = hfst_dev.exceptions.EmptyStringException('foo','bar', 10)
e = hfst_dev.exceptions.SymbolNotFoundException('foo','bar', 10)
e = hfst_dev.exceptions.MetadataException('foo','bar', 10)
e = hfst_dev.exceptions.FlagDiacriticsAreNotIdentitiesException('foo','bar', 10)

import hfst_dev

# Test that importing exceptions via a package works
if hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.FOMA_TYPE) and hfst_dev.HfstTransducer.is_implementation_type_available(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE):
    try:
        foo = hfst_dev.regex('foo')
        bar = hfst_dev.regex('bar')
        foo.convert(hfst_dev.ImplementationType.FOMA_TYPE)
        bar.convert(hfst_dev.ImplementationType.TROPICAL_OPENFST_TYPE)
        foo.concatenate(bar)
        assert False
    except hfst_dev.exceptions.TransducerTypeMismatchException as e:
        pass

