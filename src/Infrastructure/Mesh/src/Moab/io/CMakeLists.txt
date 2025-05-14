
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_compile_definitions(esmf PRIVATE IS_BUILDING_MB HAVE_VSNPRINTF LINUX USE_MPI)
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/io/.. ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab/io/../parallel)
target_sources(esmf PRIVATE ExoIIUtil.cpp FileTokenizer.cpp GmshUtil.cpp IODebugTrack.cpp ReadABAQUS.cpp ReadGmsh.cpp ReadIDEAS.cpp ReadMCNP5.cpp ReadNASTRAN.cpp ReadOBJ.cpp ReadRTT.cpp ReadSmf.cpp ReadSms.cpp ReadSTL.cpp ReadTemplate.cpp ReadTetGen.cpp ReadVtk.cpp SMF_State.cpp Tqdcfr.cpp VtkUtil.cpp WriteAns.cpp WriteGmsh.cpp WriteGMV.cpp WriteSmf.cpp WriteSTL.cpp WriteTemplate.cpp WriteVtk.cpp NCHelper.cpp NCHelperEuler.cpp NCHelperFV.cpp NCHelperGCRM.cpp NCHelperHOMME.cpp NCHelperMPAS.cpp NCWriteEuler.cpp NCWriteFV.cpp NCWriteGCRM.cpp NCWriteHelper.cpp NCWriteHOMME.cpp NCWriteMPAS.cpp ReadNC.cpp ReadNCDF.cpp)
