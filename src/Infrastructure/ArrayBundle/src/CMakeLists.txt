
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/ArrayBundle/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_ArrayBundle.C)
target_sources(esmf PUBLIC ../include/ESMCI_ArrayBundle.h)
