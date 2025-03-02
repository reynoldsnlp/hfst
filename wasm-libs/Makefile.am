EXTRA_DIST =

MAINTAINERCLEANFILES = Makefile.in

all-local: libfoma.a libfst.a

libfoma.a:
	cd foma/foma && \
	git pull && \
	emcmake cmake . && \
	$(EMMAKE) make VERBOSE=1 && \
	cp libfoma.a $(abs_builddir)/

libfst.a:
	cd openfst && \
	emconfigure ./configure --enable-static --disable-shared && \
	$(EMMAKE) make VERBOSE=1 && \
	cp src/lib/.libs/libfst.a $(abs_builddir)/

clean-local:
	rm -f libfoma.a libfst.a && \
	cd foma/foma && make clean && cd ../.. && \
	cd openfst && make clean
