
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_compile_definitions(esmf PRIVATE MPICH_IGNORE_CXX_SEEK)
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab)
target_sources(esmf PRIVATE ESMCI_Mesh_F.C ESMC_Mesh.C)
target_sources(esmf PRIVATE ESMF_Mesh.F90 ESMF_Mesh_C.F90)
target_sources(esmf PUBLIC ../include/ESMC_Mesh.h)
