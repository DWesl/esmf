
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Field/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_FieldGet.F90
    MAIN_DEPENDENCY ESMF_FieldGet.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FieldGet.cppF90 ${ESMF_BINARY_DIR}/ESMF_FieldGet.F90)
add_custom_command(OUTPUT ESMF_FieldEmpty.F90
    MAIN_DEPENDENCY ESMF_FieldEmpty.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FieldEmpty.cppF90 ${ESMF_BINARY_DIR}/ESMF_FieldEmpty.F90)
add_custom_command(OUTPUT ESMF_FieldCreate.F90
    MAIN_DEPENDENCY ESMF_FieldCreate.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FieldCreate.cppF90 ${ESMF_BINARY_DIR}/ESMF_FieldCreate.F90)
add_custom_command(OUTPUT ESMF_FieldGather.F90
    MAIN_DEPENDENCY ESMF_FieldGather.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FieldGather.cppF90 ${ESMF_BINARY_DIR}/ESMF_FieldGather.F90)
add_custom_command(OUTPUT ESMF_FieldScatter.F90
    MAIN_DEPENDENCY ESMF_FieldScatter.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FieldScatter.cppF90 ${ESMF_BINARY_DIR}/ESMF_FieldScatter.F90)
set(AUTOGEN ESMF_FieldGet.F90 ESMF_FieldEmpty.F90 ESMF_FieldCreate.F90 ESMF_FieldGather.F90 ESMF_FieldScatter.F90)
target_sources(esmf PRIVATE ESMF_Field.F90 ESMF_FieldPr.F90 ${AUTOGEN} ESMF_FieldGetAllocBounds.F90 ESMF_FieldWr.F90 ESMF_FieldRedist.F90 ESMF_FieldSMM.F90 ESMF_FieldHalo.F90 ESMF_FieldRegrid.F90 ESMF_FieldSet.F90 ESMF_UtilRWG.F90)
