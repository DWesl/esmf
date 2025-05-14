
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_compile_definitions(esmf PRIVATE IS_BUILDING_MB HAVE_VSNPRINTF LINUX USE_MPI)
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/verdict/..)
target_sources(esmf PRIVATE V_EdgeMetric.cpp VerdictVector.cpp VerdictWrapper.cpp V_GaussIntegration.cpp V_HexMetric.cpp V_KnifeMetric.cpp V_PyramidMetric.cpp V_QuadMetric.cpp V_TetMetric.cpp V_TriMetric.cpp V_WedgeMetric.cpp)
