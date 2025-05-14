
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Util/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_FortranWordsize.F90
    MAIN_DEPENDENCY ESMF_FortranWordsize.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FortranWordsize.cppF90 ${ESMF_BINARY_DIR}/ESMF_FortranWordsize.F90)
add_custom_command(OUTPUT ESMF_TypeKindGet.F90
    MAIN_DEPENDENCY ESMF_TypeKindGet.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_TypeKindGet.cppF90 ${ESMF_BINARY_DIR}/ESMF_TypeKindGet.F90)
add_custom_command(OUTPUT ESMF_UtilSort.F90
    MAIN_DEPENDENCY ESMF_UtilSort.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_UtilSort.cppF90 ${ESMF_BINARY_DIR}/ESMF_UtilSort.F90)
set(AUTOGEN ESMF_FortranWordsize.F90 ESMF_TypeKindGet.F90 ESMF_UtilSort.F90)
target_sources(esmf PRIVATE ESMCI_Util.C ESMCI_Fraction.C ESMCI_F90Interface.C ESMCI_CoordSys.C)
target_sources(esmf PRIVATE ESMF_UtilTypes.F90 ESMF_UtilString.F90 ESMF_LogErr.F90 ${AUTOGEN} ESMF_InitMacros.F90 ESMF_IOUtil.F90 ESMF_StaggerLocType.F90 ESMF_UtilCubedSphere.F90 ESMF_AttPackType.F90)
target_sources(esmf PUBLIC ../include/ESMCI_Arg.h ../include/ESMF_Macros.inc ../include/ESMF.h ../include/ESMCI_Util.h ../include/ESMF_TypeKindRankMacros.hcppF90 ../include/ESMCI_Macros.h ../include/ESMCI_F90Interface.h ../include/ESMF_ErrReturnCodes.inc ../include/ESMF_LogMacros.inc ../include/ESMF_LogConstants.inc ../include/ESMCI_Fraction.h ../include/ESMF_TypeKindMacros.hcppF90 ../include/ESMF_InitMacros.inc ../include/ESMCI_CoordSys.h)
