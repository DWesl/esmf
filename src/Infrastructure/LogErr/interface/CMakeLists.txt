
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/LogErr/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_LogErr_F.C ESMC_LogErr.C)
target_sources(esmf PRIVATE ESMF_LogErr_C.F90 ESMF_LogPublic.F90)
target_sources(esmf PRIVATE ../include/ESMC_LogErr.h)
