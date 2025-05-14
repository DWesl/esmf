
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Array/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_ArrayCreate.F90
    MAIN_DEPENDENCY ESMF_ArrayCreate.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_ArrayCreate.cppF90 ${ESMF_BINARY_DIR}/ESMF_ArrayCreate.F90)
add_custom_command(OUTPUT ESMF_ArrayGet.F90
    MAIN_DEPENDENCY ESMF_ArrayGet.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_ArrayGet.cppF90 ${ESMF_BINARY_DIR}/ESMF_ArrayGet.F90)
add_custom_command(OUTPUT ESMF_ArrayGather.F90
    MAIN_DEPENDENCY ESMF_ArrayGather.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_ArrayGather.cppF90 ${ESMF_BINARY_DIR}/ESMF_ArrayGather.F90)
add_custom_command(OUTPUT ESMF_ArrayScatter.F90
    MAIN_DEPENDENCY ESMF_ArrayScatter.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_ArrayScatter.cppF90 ${ESMF_BINARY_DIR}/ESMF_ArrayScatter.F90)
set(AUTOGEN ESMF_ArrayCreate.F90 ESMF_ArrayGet.F90 ESMF_ArrayGather.F90 ESMF_ArrayScatter.F90)
target_sources(esmf PRIVATE ESMCI_Array_F.C ESMC_Array.C)
target_sources(esmf PRIVATE ${AUTOGEN} ESMF_DynamicMask.F90 ESMF_ArrayHa.F90 ESMF_Array.F90)
target_sources(esmf PUBLIC ../include/ESMC_Array.h)
