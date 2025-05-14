
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Util/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_Util_F.C ESMC_Util.C ESMCI_F90Interface_F.C ESMC_Interface.C ESMCI_Fraction_F.C)
target_sources(esmf PRIVATE ESMF_Util.F90 ESMF_F90Interface.F90 ESMF_Fraction.F90 ESMF_Util_C.F90)
target_sources(esmf PUBLIC ../include/ESMC_Arg.h ../include/ESMC_Interface.h ../include/ESMC_Macros.h ../include/ESMC_Util.h ../include/ESMC_ReturnCodes.h ../include/ESMC_CoordSys.h)
