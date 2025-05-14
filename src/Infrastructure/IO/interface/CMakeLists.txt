
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/IO/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_custom_command(OUTPUT ESMF_IO_NCPutGet.F90
    MAIN_DEPENDENCY ESMF_IO_NCPutGet.cppF90
    VERBATIM
    COMMAND ${ESMF_BINARY_DIR}/cppF90_to_F90 ${ESMF_SOURCE_DIR}/ESMF_IO_NCPutGet.cppF90 ${ESMF_BINARY_DIR}/ESMF_IO_NCPutGet.F90)
set(AUTOGEN ESMF_IO_NCPutGet.F90)
target_sources(esmf PRIVATE ESMCI_IO_NetCDF_F.C ESMC_IOScrip2ESMF.C ESMCI_IO_F.C ESMC_IO_Gridspec.C ESMC_IO_Scrip.C ESMCI_IO_YAML_F.C)
target_sources(esmf PRIVATE ESMF_IO_NetCDF.F90 ESMF_IOUGrid.F90 ESMF_IOGridspec.F90 ESMF_IOGridmosaic.F90 ESMF_IOScrip.F90 ${AUTOGEN} ESMF_IOFileTypeCheck.F90 ESMF_IO.F90 ESMF_IO_Gridspec_C.F90 ESMF_IO_Scrip_C.F90 ESMF_IO_YAML.F90)
