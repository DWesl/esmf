
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_FieldBundle.F90
    MAIN_DEPENDENCY ESMF_FieldBundle.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_FieldBundle.cppF90 ${ESMF_BINARY_DIR}/ESMF_FieldBundle.F90)
set(AUTOGEN ESMF_FieldBundle.F90)
target_sources(esmf PRIVATE ${AUTOGEN})
