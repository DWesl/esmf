
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Superstructure/Mapper/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_RunSeqDGraph.C ESMCI_GraphDotUtils.C ESMCI_RunSeqUtils.C ESMCI_Mapper.C)
