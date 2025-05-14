
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()

# if((ESMF_COMM STREQUAL mpich1) OR (ESMF_COMM STREQUAL mpich2) OR (ESMF_COMM STREQUAL mpich))
if(ESMF_COMM MATCHES "^mpich")
  target_compile_definitions(esmf PRIVATE MPICH_IGNORE_CXX_SEEK)
endif()

add_subdirectory(Legacy)
if(ESMF_MOAB)
  add_subdirectory(Moab)
endif()
add_subdirectory(Zoltan)
if(ESMF_LAPACK STREQUAL internal)
  add_subdirectory(BLAS)
endif()
if(ESMF_LAPACK STREQUAL internal)
  add_subdirectory(Lapack)
  target_sources(esmf PUBLIC ../include/ESMF_LapackBlas.inc)
endif()

add_subdirectory(Regridding)

target_sources(esmf PRIVATE ESMCI_ClumpPnts.C ESMCI_MathUtil.C
  ESMCI_Mesh_Glue.C ESMCI_FileIO_Util.C ESMCI_ESMFMesh_Util.C
  ESMCI_UGRID_Util.C ESMCI_Mesh_FileIO.C ESMCI_GToM_Util.C
  ESMCI_Mesh_GToM_Glue.C ESMCI_Mesh_Vector_Regrid.C
  ESMCI_Mesh_Regrid_Glue.C ESMCI_Mesh_XGrid_Glue.C ESMCI_Mesh.C
  ESMCI_MeshCap.C ESMCI_MeshCXX.C ESMCI_MeshDual.C ESMCI_MeshRedist.C
  ESMCI_OTree.C ESMCI_Regrid_Nearest.C ESMCI_Rendez_Nearest.C
  ESMCI_Search_Nearest.C ESMCI_Search_NearestNPnts.C
  ESMCI_XGridUtil.C)

if(NOT (ESMF_MOAB STREQUAL OFF))
  target_sources(esmf PRIVATE ESMCI_MBMesh.C ESMCI_MBMesh_BBox.C
    ESMCI_MBMesh_Bilinear.C ESMCI_MBMesh_Conserve.C
    ESMCI_MBMesh_Dual.C ESMCI_MBMesh_Extrapolation.C
    ESMCI_MBMesh_Glue.C ESMCI_MBMesh_GToM_Glue.C
    ESMCI_MBMesh_Mapping.C ESMCI_MBMesh_Patch.C ESMCI_MBMesh_Redist.C
    ESMCI_MBMesh_Regrid_Glue.C ESMCI_MBMesh_Rendez_Elem.C
    ESMCI_MBMesh_Rendez_EtoP.C ESMCI_MBMesh_Search_EtoE.C
    ESMCI_MBMesh_Search_EtoP.C ESMCI_MBMesh_ShapeFunc.C
    ESMCI_MBMesh_Util.C)
endif()
if(ESMF_MOAD STREQUAL internal)
  target_include_directories(esmf PRIVATE
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/parallel
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/LocalDiscretization)
endif()

target_sources(esmf PRIVATE ../include/ESMCI_MeshCXX.h)
target_sources(esmf PUBLIC ../include/ESMCI_MeshCXX.h)
