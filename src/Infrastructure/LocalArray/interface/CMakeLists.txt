
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/LocalArray/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_LocalArrayWrapperType.F90
    MAIN_DEPENDENCY ESMF_LocalArrayWrapperType.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_LocalArrayWrapperType.cppF90 ${ESMF_BINARY_DIR}/ESMF_LocalArrayWrapperType.F90)
add_custom_command(OUTPUT ESMF_LocalArrayCreate.F90
    MAIN_DEPENDENCY ESMF_LocalArrayCreate.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_LocalArrayCreate.cppF90 ${ESMF_BINARY_DIR}/ESMF_LocalArrayCreate.F90)
add_custom_command(OUTPUT ESMF_LocalArrayGet.F90
    MAIN_DEPENDENCY ESMF_LocalArrayGet.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_LocalArrayGet.cppF90 ${ESMF_BINARY_DIR}/ESMF_LocalArrayGet.F90)
set(AUTOGEN ESMF_LocalArrayWrapperType.F90 ESMF_LocalArrayCreate.F90 ESMF_LocalArrayGet.F90)
target_sources(esmf PRIVATE ESMCI_LocalArray_F.C)
target_sources(esmf PRIVATE ${AUTOGEN} ESMF_LocalArray.F90 ESMF_LocalArray_C.F90)
