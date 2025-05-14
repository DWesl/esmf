
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/GridUtil/tests/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_executable(ESMF_GridToMeshUTest  ESMF_GridToMeshUTest.F90)
target_link_libraries(ESMF_GridToMeshUTest esmf)
if(ESMF_OPENMP)
target_link_libraries(ESMF_GridToMeshUTest OpenMP::OpenMP_Fortran)
endif()
add_test(RUN_ESMF_GridToMeshUTest COMMAND ESMF_GridToMeshUTest)
set_property(TEST RUN_ESMF_GridToMeshUTest PROPERTY LABEL MPI )
