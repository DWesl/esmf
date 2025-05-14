
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/VM/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_subdirectory(acc)
target_sources(esmf PRIVATE ESMCI_VM.C ESMCI_VMKernel.C)
target_sources(esmf PUBLIC ../include/ESMCI_VM.h ../include/ESMCI_VMKernel.h ../include/ESMCI_AccInfo.h)
