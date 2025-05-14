
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/IO/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_IO_NetCDF_Utils.C ESMCI_IO_NetCDF.C ESMCI_IO.C ESMCI_IO_Handler.C ESMCI_IO_Gridspec.C ESMCI_IO_Scrip.C ESMCI_IO_YAML.C ESMCI_PIO_Handler.C)
target_sources(esmf PUBLIC ../include/ESMCI_IO_NetCDF_Utils.h ../include/ESMCI_IO_NetCDF.h ../include/ESMCI_IO.h ../include/ESMCI_IO_Handler.h ../include/ESMCI_IO_Gridspec.h ../include/ESMCI_IO_Scrip.h ../include/ESMCI_IO_YAML.h ../include/ESMCI_PIO_Handler.h)
