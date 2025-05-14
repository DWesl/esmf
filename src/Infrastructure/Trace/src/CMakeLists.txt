
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Trace/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE esmftrc.c ESMCI_Trace.C ESMCI_TraceWrap.C ESMCI_TraceMetadata.C ESMCI_TraceClock.C)
target_sources(esmf PRIVATE ../include/esmftrc.h ../include/ESMCI_Trace.h ../include/ESMCI_TraceUtil.h ../include/ESMCI_HashMap.h ../include/ESMCI_HashNode.h ../include/ESMCI_KeyHash.h ../include/ESMCI_RegionNode.h ../include/ESMCI_ComponentInfo.h ../include/ESMCI_TraceRegion.h ../include/ESMCI_RegionSummary.h)
target_sources(esmf PUBLIC ../include/ESMCI_TraceRegion.h ../include/ESMF_TraceRegion.inc ../include/ESMCI_TraceMacros.h)
