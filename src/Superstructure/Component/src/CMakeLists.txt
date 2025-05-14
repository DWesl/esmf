
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Superstructure/Component/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_FTable.C ESMCI_MethodTable.C ESMCI_CompTunnel.C)
target_sources(esmf PRIVATE ESMF_Comp.F90 ESMF_GridComp.F90 ESMF_CplComp.F90 ESMF_SciComp.F90)
target_sources(esmf PUBLIC ../include/ESMCI_FTable.h ../include/ESMCI_MethodTable.h ../include/ESMCI_CompTunnel.h)
