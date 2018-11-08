# -*- coding: utf-8 -*-
import sys
if len(sys.argv) > 1:
    sys.path.insert(0, sys.argv[1])
import hfst_dev.exceptions

diritems = \
['ContextTransducersAreNotAutomataException', 'EmptySetOfContextsException', 'EmptyStringException', \
 'EndOfStreamException', 'FlagDiacriticsAreNotIdentitiesException', 'FunctionNotImplementedException', \
 'HfstException', 'HfstFatalException', 'HfstTransducerTypeMismatchException', \
 'ImplementationTypeNotAvailableException', 'IncorrectUtf8CodingException', 'MetadataException', \
 'MissingOpenFstInputSymbolTableException', 'NotTransducerStreamException', 'NotValidAttFormatException', \
 'NotValidLexcFormatException', 'NotValidPrologFormatException', 'SpecifiedTypeRequiredException', \
 'StateIndexOutOfBoundsException', 'StateIsNotFinalException', 'StreamCannotBeWrittenException', \
 'StreamIsClosedException', 'StreamNotReadableException', 'SymbolNotFoundException', \
 'TransducerHasWrongTypeException', 'TransducerHeaderException', 'TransducerIsCyclicException', \
 'TransducerTypeMismatchException', 'TransducersAreNotAutomataException']

dirhfstexceptions = dir(hfst_dev.exceptions)

for item in diritems:
    assert item in dirhfstexceptions
