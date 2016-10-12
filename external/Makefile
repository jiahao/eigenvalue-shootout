CC=gcc
FC=gfortran
CFLAGS=-O3 -Wall
FFLAGS=$(CFLAGS)

#How to link LAPACK library
LAPACK=-llapack

#How to link BLAS library
BLAS=-lblas

EVSL_VER=1.0
SUITESPARSE_VER=4.5.3

SHARED_LIB_EXT=dylib

srccache = srccache
suitesparse_dl=SuiteSparse-$(SUITESPARSE_VER).tar.gz
suitesparse_lib=$(CURDIR)/SuiteSparse/lib/libsuitesparseconfig.$(SHARED_LIB_EXT)
evsl_lib=$(CURDIR)/EVSL_$(EVSL_VER)/liblancheb.a

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
	cd EVSL_$(EVSL_VER) && mv makefile.in{,.orig} && mv makefile.in{_MacOS.example,}

$(evsl_lib): EVSL_$(EVSL_VER)
	cd EVSL_$(EVSL_VER) && make CC="$(CC)" LINK="$(CC)" FLAGS="$(CFLAGS)" LIBLAPACK="$(LAPACK) $(BLAS)"

EVSL_1.0/TESTS_LAP/LapPLanR.ex: $(evsl_lib)
	cd EVSL_1.0/TESTS_LAP && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" -f makefileP LapPLanR.ex && ./LapPLanR.ex

EVSL_1.0/TESTS_LAP/LapPLanN.ex: $(evsl_lib)
	cd EVSL_1.0/TESTS_LAP && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" -f makefileP LapPLanN.ex && ./LapPlanN.ex

EVSL_1.0/TESTS_LAP/LapPSI.ex: $(evsl_lib)
	cd EVSL_1.0/TESTS_LAP && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" -f makefileP LapPSI.ex   && ./LapPSI.ex

EVSL_1.0/TESTS_LAP/LapRLanR.ex: $(evsl_lib) $(suitesparse_lib)
	cd EVSL_1.0/TESTS_LAP && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" EXTLIB="$(EXTLIB)" LIB_UMF="$(LIB_UMF)" -f makefileR LapRLanR.ex && ./LapRLanR.ex

EVSL_1.0/TESTS_LAP/LapRLanN.ex: $(evsl_lib) $(suitesparse_lib)
	cd EVSL_1.0/TESTS_LAP && make CC="$(CC)" FLAGS="$(CFLAGS)" LINK="$(CC)" EXTLIB="$(EXTLIB)" LIB_UMF="$(LIB_UMF)" -f makefileR LapRLanN.ex && ./LapRLanN.ex

evsl_tested: $(evsl_lib) EVSL_1.0/TESTS_LAP/LapPLanR.ex EVSL_1.0/TESTS_LAP/LapPLanN.ex EVSL_1.0/TESTS_LAP/LapPSI.ex EVSL_1.0/TESTS_LAP/LapRLanR.ex EVSL_1.0/TESTS_LAP/LapRLanN.ex

