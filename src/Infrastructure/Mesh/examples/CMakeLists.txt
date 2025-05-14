
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_compile_definitions(esmf PRIVATE MPICH_IGNORE_CXX_SEEK)
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../include ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../include/Legacy ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../include/Regridding ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../src/Moab ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../src/Moab/parallel ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/examples/../src/Moab/LocalDiscretization)
