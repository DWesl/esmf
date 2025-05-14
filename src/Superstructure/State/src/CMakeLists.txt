
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Superstructure/State/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_StateInternals.F90
    MAIN_DEPENDENCY ESMF_StateInternals.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_StateInternals.cppF90 ${ESMF_BINARY_DIR}/ESMF_StateInternals.F90)
add_custom_command(OUTPUT ESMF_StateRemRep.F90
    MAIN_DEPENDENCY ESMF_StateRemRep.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_StateRemRep.cppF90 ${ESMF_BINARY_DIR}/ESMF_StateRemRep.F90)
add_custom_command(OUTPUT ESMF_StateAPI.F90
    MAIN_DEPENDENCY ESMF_StateAPI.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_StateAPI.cppF90 ${ESMF_BINARY_DIR}/ESMF_StateAPI.F90)
set(AUTOGEN ESMF_StateInternals.F90 ESMF_StateRemRep.F90 ESMF_StateAPI.F90)
target_sources(esmf PRIVATE ESMF_StateItem.F90 ESMF_StateContainer.F90 ESMF_StateTypes.F90 ESMF_StateVa.F90 ESMF_State.F90 ESMF_StateWr.F90 ${AUTOGEN} ESMF_StateSet.F90)
target_sources(esmf PUBLIC ../include/ESMCI_StateItem.h ../include/ESMC_State.h)
