AM_CXXFLAGS= -Wcast-qual -Wno-deprecated -Wfatal-errors

bin_PROGRAMS=hfst-twolc
bin_SCRIPTS=

AM_CPPFLAGS = -I${top_srcdir}/libhfst/src -I${top_srcdir}/libhfst/src/parsers
LDADD = $(top_builddir)/libhfst/src/libhfst.la

hfst_twolc_SOURCES=hfst-twolc.cc
