# $Id$ 

ALL: tree_build_system_tests
run: tree_run_system_tests
run_uni:  tree_run_system_tests_uni

LOCDIR	  = src/system_tests/ESMF_FieldSharedDeSSI

SYSTEM_TESTS_BUILD    = $(ESMC_TESTDIR)/ESMF_FieldSharedDeSSISTest

# Object files other than SysTest%.o that the
# system tests executable will depend on.
# List objects files in the order that they
# are to be compiled/created.
SYSTEM_TESTS_OBJ      = user_model1.o user_model2.o

SYSTEM_TESTS_RUN      = RUN_FieldSharedDeSSI

SYSTEM_TESTS_RUN_UNI  = RUN_FieldSharedDeSSIUNI

ESMF_FieldSharedDeSSISTest.o : $(SYSTEM_TESTS_OBJ)

include $(ESMF_DIR)/makefile

DIRS = 

CLEANDIRS   =
CLEANFILES  = $(SYSTEM_TESTS_BUILD)
CLOBBERDIRS =


RUN_FieldSharedDeSSI:
	env OMP_WAIT_POLICY=passive $(MAKE) TNAME=FieldSharedDeSSI NP=6 stest

RUN_FieldSharedDeSSIUNI:
	$(MAKE) TNAME=FieldSharedDeSSI NP=1 stest
