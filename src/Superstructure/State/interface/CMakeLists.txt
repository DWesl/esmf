
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Superstructure/State/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_State.C ESMC_State.C ESMCI_State_F.C)
target_sources(esmf PRIVATE ESMF_State_C.F90)
target_sources(esmf PUBLIC ../include/ESMCI_State.h ../include/ESMC_State.h)
