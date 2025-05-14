
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()

target_compile_definitions(esmf PRIVATE MPICH_IGNORE_CXX_SEEK)

if(ESMF_MOAB STREQUAL internal)
  target_include_directories(esmf PRIVATE
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Regridding/../Moab
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Regridding/../Moab/parallel
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Regridding/../Moab/LocalDiscretization)
endif()

target_sources(esmf PRIVATE ESMCI_Conserve2ndInterp.C
  ESMCI_ConserveInterp.C ESMCI_ExtrapolationPoleLGC.C
  ESMCI_Integrate.C ESMCI_Interp.C ESMCI_Mapping.C ESMCI_CreepFill.C
  ESMCI_Extrap.C ESMCI_MeshRegrid.C ESMCI_PatchRecovery.C
  ESMCI_Regrid_Helper.C ESMCI_Search.C ESMCI_SearchNearestDToSLGC.C
  ESMCI_SearchNearestLGC.C ESMCI_SearchNearestNPntsLGC.C
  ESMCI_ShapeFunc.C ESMCI_SpaceDir.C ESMCI_WMat.C)
