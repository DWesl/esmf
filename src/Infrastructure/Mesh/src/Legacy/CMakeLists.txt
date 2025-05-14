
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
if(ESMF_COMM MATCHES "^mpich")
target_compile_definitions(esmf PRIVATE MPICH_IGNORE_CXX_SEEK)
endif()

if(ESMF_MOAB STREQUAL internal)
target_include_directories(esmf PRIVATE
  ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Legacy/..
  ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Legacy/../Moab
  ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Legacy/../Moab/parallel
  ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Legacy/../Moab/LocalDiscretization)
endif()

target_sources(esmf PRIVATE ESMCI_Attr.C ESMCI_BBox.C ESMCI_CommReg.C
  ESMCI_CommRel.C ESMCI_Context.C ESMCI_DDir.C ESMCI_Exception.C
  ESMCI_FieldReg.C ESMCI_GeomRendezvous.C ESMCI_GlobalIds.C
  ESMCI_HAdapt.C ESMCI_IOField.C ESMCI_Kernel.C ESMCI_MasterElement.C
  ESMCI_MCoord.C ESMCI_MEFamily.C ESMCI_MEField.C ESMCI_MEImprint.C
  ESMCI_MeshDB.C ESMCI_MeshExodus.C ESMCI_MeshField.C ESMCI_MeshGen.C
  ESMCI_MeshllField.C ESMCI_MeshMerge.C ESMCI_MeshNC.C ESMCI_MeshObj.C
  ESMCI_MeshObjConn.C ESMCI_MeshObjPack.C ESMCI_MeshObjTopo.C
  ESMCI_MeshPartition.C ESMCI_MeshPNC.C ESMCI_MeshRead.C
  ESMCI_MeshRefine.C ESMCI_MeshSkin.C ESMCI_MeshUtils.C
  ESMCI_MeshVTK.C ESMCI_MEValues.C ESMCI_Migrator.C ESMCI_ParEnv.C
  ESMCI_ParLog.C ESMCI_Phedra.C ESMCI_Polynomial.C ESMCI_Quadrature.C
  ESMCI_Rebalance.C ESMCI_RefineTopo.C ESMCI_SFuncAdaptor.C
  ESMCI_ShapeLagrange.C ESMCI_SmallAlloc.C ESMCI_SparseMsg.C
  ESMCI_WriteWeights.C ESMCI_WriteWeightsPar.C ESMCI_FindPnts.C
  ESMCI_SM.C)

target_sources(esmf PRIVATE ESMF_SolverUtil_C.F90)
