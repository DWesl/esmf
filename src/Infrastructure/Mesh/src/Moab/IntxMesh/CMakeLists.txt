
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_compile_definitions(esmf PRIVATE IS_BUILDING_MB HAVE_VSNPRINTF LINUX USE_MPI)
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/IntxMesh/.. ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/IntxMesh/../parallel)
target_sources(esmf PRIVATE Intx2Mesh.cpp Intx2MeshInPlane.cpp Intx2MeshOnSphere.cpp IntxRllCssphere.cpp IntxUtils.cpp)
