AM_CXXFLAGS= -O3 -g -Wall -Wextra -Wcast-qual -Wno-deprecated -Wfatal-errors -Wno-sign-compare\
             -I$(top_builddir)/tools/src/inc -I$(top_builddir)/tools/src

bin_PROGRAMS=hfst-tag hfst-reweight-tagger$(EXEEXT)
bin_SCRIPTS=
EXTRA_DIST=

BUILD_MODEL_SRC=$(srcdir)/build_model_src
USE_MODEL_SRC=$(srcdir)/use_model_src
AM_CPPFLAGS=-I${top_srcdir}/libhfst/src -Wno-sign-compare -Wno-unused-parameter
LDADD = $(top_builddir)/libhfst/src/libhfst.la

EXTRA_DIST += $(BUILD_MODEL_SRC)/tagger_aux.py

HFST_COMMON_SRC=$(top_srcdir)/tools/src/hfst-program-options.cc \
                $(top_srcdir)/tools/src/hfst-commandline.cc \
	        $(top_srcdir)/tools/src/hfst-tool-metadata.cc

hfst_tag_SOURCES=hfst-tag.cc \
	         $(USE_MODEL_SRC)/DelayedSequenceModelComponent.cc \
                 $(USE_MODEL_SRC)/AcyclicAutomaton.cc \
	         $(USE_MODEL_SRC)/NewLexicalModel.cc \
                 $(USE_MODEL_SRC)/SentenceTagger.cc \
                 $(USE_MODEL_SRC)/SentenceTransducer.cc \
	         $(USE_MODEL_SRC)/SequenceModelComponent.cc \
	         $(USE_MODEL_SRC)/SequenceModelComponentPair.cc \
                 $(USE_MODEL_SRC)/SequenceTagger.cc \
		 $(HFST_COMMON_SRC)

hfst_reweight_tagger_SOURCES=hfst-reweight-tagger.cc \
		             $(HFST_COMMON_SRC)


unit_test_aux.o:$(srcdir)/unit_test_aux.cc

check_PROGRAMS=DelayedSequenceModelComponent \
               AcyclicAutomaton NewLexicalModel SentenceTagger \
               SentenceTransducer SequenceModelComponent \
               SequenceModelComponentPair SequenceTagger

AcyclicAutomaton_SOURCES=$(USE_MODEL_SRC)/AcyclicAutomaton.cc

AcyclicAutomaton_LDADD=AcyclicAutomaton.o $(top_srcdir)/libhfst/src/libhfst.la\
		       SequenceModelComponent.o unit_test_aux.o
AcyclicAutomaton_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

DelayedSequenceModelComponent_SOURCES= \
                       $(USE_MODEL_SRC)/DelayedSequenceModelComponent.cc

DelayedSequenceModelComponent_LDADD=DelayedSequenceModelComponent.o \
                       $(top_srcdir)/libhfst/src/libhfst.la \
		       SequenceModelComponent.o unit_test_aux.o
DelayedSequenceModelComponent_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

NewLexicalModel_SOURCES=$(USE_MODEL_SRC)/NewLexicalModel.cc

NewLexicalModel_LDADD=NewLexicalModel.o $(top_srcdir)/libhfst/src/libhfst.la \
		      unit_test_aux.o
NewLexicalModel_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

SentenceTagger_SOURCES=$(USE_MODEL_SRC)/SentenceTagger.cc

SentenceTagger_LDADD=SentenceTagger.o $(top_srcdir)/libhfst/src/libhfst.la \
		     DelayedSequenceModelComponent.o SequenceModelComponent.o \
		     SentenceTransducer.o NewLexicalModel.o \
                     SequenceModelComponentPair.o unit_test_aux.o \
                     SequenceTagger.o AcyclicAutomaton.o

SentenceTagger_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

SentenceTransducer_SOURCES=$(USE_MODEL_SRC)/SentenceTransducer.cc

SentenceTransducer_LDADD=SentenceTransducer.o \
                       $(top_srcdir)/libhfst/src/libhfst.la \
		       SequenceModelComponent.o unit_test_aux.o
SentenceTransducer_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

SequenceModelComponent_SOURCES=$(USE_MODEL_SRC)/SequenceModelComponent.cc\
			       unit_test_aux.cc
SequenceModelComponent_LDADD=SequenceModelComponent.o \
                             $(top_srcdir)/libhfst/src/libhfst.la
SequenceModelComponent_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

SequenceModelComponentPair_SOURCES= \
                                $(USE_MODEL_SRC)/SequenceModelComponentPair.cc

SequenceModelComponentPair_LDADD=SequenceModelComponentPair.o \
                                 $(top_srcdir)/libhfst/src/libhfst.la \
                                 DelayedSequenceModelComponent.o \
				 SequenceModelComponent.o unit_test_aux.o
SequenceModelComponentPair_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

SequenceTagger_SOURCES=$(USE_MODEL_SRC)/SequenceTagger.cc

SequenceTagger_LDADD=SequenceTagger.o $(top_srcdir)/libhfst/src/libhfst.la\
		     SequenceModelComponent.o SentenceTransducer.o \
                     unit_test_aux.o AcyclicAutomaton.o \
                     SequenceModelComponentPair.o \
		     DelayedSequenceModelComponent.o
SequenceTagger_CXXFLAGS=-DMAIN_TEST -Wno-deprecated

TESTS=$(check_PROGRAMS)

EXTRA_DIST += $(BUILD_MODEL_SRC)/FstBuilder.h \
$(BUILD_MODEL_SRC)/LexicalModelBuilder.h \
$(BUILD_MODEL_SRC)/ModelBuilder.h \
$(BUILD_MODEL_SRC)/SequenceModelBuilder.h \
$(BUILD_MODEL_SRC)/string_handling.h \
$(BUILD_MODEL_SRC)/TaggerBuilder.h \
$(BUILD_MODEL_SRC)/WeightedStringVectorCollection.h \
unit_test_aux.h \
$(USE_MODEL_SRC)/AcyclicAutomaton.h \
$(USE_MODEL_SRC)/DataTypes.h \
$(USE_MODEL_SRC)/DelayedSequenceModelComponent.h \
$(USE_MODEL_SRC)/NewLexicalModel.h \
$(USE_MODEL_SRC)/SentenceTagger.h \
$(USE_MODEL_SRC)/SentenceTransducer.h \
$(USE_MODEL_SRC)/SequenceModelComponent.h \
$(USE_MODEL_SRC)/SequenceModelComponentPair.h \
$(USE_MODEL_SRC)/SequenceTagger.h
