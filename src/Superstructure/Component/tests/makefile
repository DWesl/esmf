# $Id$ 

ALL:      build_unit_tests
run:      run_unit_tests
run_uni:  run_unit_tests_uni

LOCDIR	  = src/Superstructure/Component/tests

.NOTPARALLEL:
TESTS_BUILD   =	$(ESMF_TESTDIR)/ESMF_ComponentUTest \
		$(ESMF_TESTDIR)/ESMF_GridCompCreateUTest \
		$(ESMF_TESTDIR)/ESMF_CplCompCreateUTest \
		$(ESMF_TESTDIR)/ESMF_SciCompCreateUTest \
		$(ESMF_TESTDIR)/ESMF_CompSetServUTest \
		$(ESMF_TESTDIR)/ESMF_StdCompMethodsUTest \
                $(ESMF_TESTDIR)/ESMF_CompTunnelUTest \
                $(ESMF_TESTDIR)/ESMC_ComponentUTest

TESTS_RUN     =	RUN_ESMF_ComponentUTest \
		RUN_ESMF_GridCompCreateUTest \
		RUN_ESMF_CplCompCreateUTest \
		RUN_ESMF_SciCompCreateUTest \
		RUN_ESMF_CompSetServUTest \
		RUN_ESMF_StdCompMethodsUTest \
		RUN_ESMF_CompTunnelUTest \
                RUN_ESMC_ComponentUTest

TESTS_RUN_UNI =	RUN_ESMF_ComponentUTestUNI \
		RUN_ESMF_GridCompCreateUTestUNI \
		RUN_ESMF_CplCompCreateUTestUNI \
		RUN_ESMF_SciCompCreateUTestUNI \
		RUN_ESMF_CompSetServUTestUNI \
		RUN_ESMF_StdCompMethodsUTestUNI \
                RUN_ESMC_ComponentUTestUNI


include $(ESMF_DIR)/makefile

CLEANDIRS   = 
CLEANFILES  = $(TESTS_BUILD)
CLOBBERDIRS =

DIRS        = 


#
# Components
#
RUN_ESMF_ComponentUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=Component NP=4 ftest

RUN_ESMF_ComponentUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=Component NP=1 ftest

# ---

RUN_ESMF_GridCompCreateUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=GridCompCreate NP=4 ftest

RUN_ESMF_GridCompCreateUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=GridCompCreate NP=1 ftest

# ---

RUN_ESMF_CplCompCreateUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=CplCompCreate NP=4 ftest

RUN_ESMF_CplCompCreateUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=CplCompCreate NP=1 ftest

# ---

RUN_ESMF_SciCompCreateUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=SciCompCreate NP=4 ftest

RUN_ESMF_SciCompCreateUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=SciCompCreate NP=1 ftest

# ---

ESMF_CompSetServUTest.o: ESMF_SetServCode.o
ESMF_UTEST_CompSetServ_OBJS = ESMF_SetServCode.o

RUN_ESMF_CompSetServUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=CompSetServ NP=4 ftest

RUN_ESMF_CompSetServUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=CompSetServ NP=1 ftest

# ---

RUN_ESMF_StdCompMethodsUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=StdCompMethods NP=4 ftest

RUN_ESMF_StdCompMethodsUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=StdCompMethods NP=1 ftest

# ---

RUN_ESMF_CompTunnelUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=CompTunnel NP=8 ftest

# ---

ESMC_ComponentUTest.o: ESMF_MyRegistrationInFortran.o
ESMC_UTEST_Component_OBJS = ESMF_MyRegistrationInFortran.o

RUN_ESMC_ComponentUTest:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=Component NP=4 ctest

RUN_ESMC_ComponentUTestUNI:
	cp -f comp.rc $(ESMF_TESTDIR)
	$(MAKE) TNAME=Component NP=1 ctest

