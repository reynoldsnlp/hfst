EXTRA_DIST =

MAINTAINERCLEANFILES = Makefile.in

all-local: libfoma.a libfst.a

libfoma.a:
	cd foma/foma && \
	git pull && \
	emcmake cmake . && \
	$(EMMAKE) make clean && \
	$(EMMAKE) make CFLAGS="-O3" && \
	cp libfoma.a $(abs_builddir)/

libfst.a:
	set -x && \
	cd openfst-copy && \
	$(EMMAKE) make clean && \
	$(EMMAKE) make CXXFLAGS="-O3" && \
	cp src/lib/libfst.a $(abs_builddir)/

clean-local:
	rm -f libfoma.a libfst.a
