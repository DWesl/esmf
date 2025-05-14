
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/addon/NUOPC/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE NUOPC_FreeFormatDef.F90 NUOPC_FieldDictionaryDef.F90 NUOPC_FieldDictionaryApi.F90 NUOPC_Auxiliary.F90 NUOPC_Base.F90 NUOPC_Compliance_Base.F90 NUOPC_Compliance_Driver.F90 NUOPC_Compliance_Model.F90 NUOPC_Compliance_Connector.F90 NUOPC_RunSequenceDef.F90 NUOPC_Comp.F90 NUOPC.F90 NUOPC_ModelBase.F90 NUOPC_Model.F90 NUOPC_Mediator.F90 NUOPC_Driver.F90 NUOPC_Connector.F90)
