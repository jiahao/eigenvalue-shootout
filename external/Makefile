CC=gcc
FC=gfortran
CFLAGS=-O3 -fPIC
FFLAGS=$(CFLAGS)
LDFLAGS=

#How to link LAPACK library
LAPACK=-llapack

#How to link BLAS library
BLAS=-lblas

EVSL_VER=1.0
SUITESPARSE_VER=4.5.3

os:=$(shell uname -s)
ifeq ($(os),Linux)
	shared_lib_ext=so
	evsl_infile=makefile.in_Linux.example
	LAPACK+=-lm -lrt
	LDFLAGS+=-Wl,-rpath=$(CURDIR)/SuiteSparse/lib -Wl,-rpath=$(CURDIR)/lib -Wl,--no-undefined
	linklancheb=-shared -Wl,-soname,liblancheb.so.1 -o ../../lib/liblancheb.so
endif
ifeq ($(os),Darwin)
	shared_lib_ext=dylib
	evsl_infile=makefile.in_MacOS.example
	linklancheb=-dynamiclib -install_name "liblancheb.1.dylib" -current_version 1.0.0 -compatibility_version 1.0 -o ../../lib/liblancheb.dylib
endif

srccache = srccache
suitesparse_dl=SuiteSparse-$(SUITESPARSE_VER).tar.gz
suitesparse_lib=$(CURDIR)/SuiteSparse/lib/libsuitesparseconfig.$(shared_lib_ext)
evsl_lib=$(CURDIR)/lib/liblancheb.$(shared_lib_ext)

#Variables to patch over EVSL 1.0 build system
EXTLIB=$(CURDIR)/SuiteSparse
LIB_UMF=-L$(EXTLIB)/lib -lumfpack -lamd -lsuitesparseconfig -lcholmod -lcolamd -lmetis -lccolamd -lcamd

.PHONY: clean distclean all evsl_tested clean-*

all: evsl_tested

clean: clean-evsl clean-suitesparse

clean-evsl:
	rm -rf EVSL_1.0

clean-suitesparse:
	rm -rf SuiteSparse

distclean: clean
	rm -rf $(srccache)

###############
# SuiteSparse #
###############

$(srccache)/$(suitesparse_dl):
	curl -o $@ http://faculty.cse.tamu.edu/davis/SuiteSparse/$(suitesparse_dl)

$(suitesparse_lib): $(srccache)/$(suitesparse_dl)
	tar xzf $(srccache)/$(suitesparse_dl)
	cd SuiteSparse && make CC="$(CC)" FC="$(FC)" CF="$(CFLAGS)" F77FLAGS="$(FFLAGS)" BLAS="$(BLAS)" LAPACK="$(LAPACK)"

####################################################
# EigenValues Slicing Library                      #
# http://www-users.cs.umn.edu/~saad/software/EVSL/ #
####################################################

$(srccache)/evsl.zip:
	mkdir -p $(srccache)
	elinks -source 1 http://www-users.cs.umn.edu/\~saad/software/EVSL/evsl.php > $(srccache)/evsl.zip

EVSL_$(EVSL_VER): $(srccache)/evsl.zip
	unzip -n $(srccache)/evsl.zip
	cd EVSL_$(EVSL_VER) && mv makefile.in makefile.orig && mv $(evsl_infile) makefile.in

$(evsl_lib): EVSL_$(EVSL_VER)
	mkdir -p lib
	cd EVSL_$(EVSL_VER)/SRC && make CC="$(CC)" LINK="$(CC)" FLAGS="$(CFLAGS) $(LDFLAGS)" LIBLAPACK="$(LAPACK) $(BLAS)" && \
		$(CC) $(LDFLAGS) $(linklancheb) *.o $(LAPACK) $(BLAS)

EVSL_1.0/TESTS_Lap/LapPLanR.ex: $(evsl_lib)
	cd EVSL_1.0/TESTS_Lap && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" LIBLAPACK="$(LAPACK) $(BLAS)" \
		-f makefileP LapPLanR.ex && ./LapPLanR.ex

EVSL_1.0/TESTS_Lap/LapPLanN.ex: $(evsl_lib)
	cd EVSL_1.0/TESTS_Lap && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" LIBLAPACK="$(LAPACK) $(BLAS)" \
		-f makefileP LapPLanN.ex && ./LapPLanN.ex

EVSL_1.0/TESTS_Lap/LapPSI.ex: $(evsl_lib)
	cd EVSL_1.0/TESTS_Lap && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" LIBLAPACK="$(LAPACK) $(BLAS)" \
		-f makefileP LapPSI.ex   && ./LapPSI.ex

EVSL_1.0/TESTS_Lap/LapRLanR.ex: $(evsl_lib) $(suitesparse_lib)
	cd EVSL_1.0/TESTS_Lap && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC) $(LDFLAGS)" LIBLAPACK="$(LAPACK) $(BLAS)" \
		EXTLIB="$(EXTLIB)" LIB_UMF="$(LIB_UMF)" -f makefileR LapRLanR.ex && ./LapRLanR.ex

EVSL_1.0/TESTS_Lap/LapRLanN.ex: $(evsl_lib) $(suitesparse_lib)
	cd EVSL_1.0/TESTS_Lap && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC) $(LDFLAGS)" LIBLAPACK="$(LAPACK) $(BLAS)" \
		EXTLIB="$(EXTLIB)" LIB_UMF="$(LIB_UMF)" -f makefileR LapRLanN.ex && ./LapRLanN.ex

evsl_tested: $(evsl_lib) EVSL_1.0/TESTS_Lap/LapPLanR.ex EVSL_1.0/TESTS_Lap/LapPLanN.ex EVSL_1.0/TESTS_Lap/LapPSI.ex EVSL_1.0/TESTS_Lap/LapRLanR.ex EVSL_1.0/TESTS_Lap/LapRLanN.ex

