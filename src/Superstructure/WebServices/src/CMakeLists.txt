
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Superstructure/WebServices/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_WebServNetEsmfClient.C ESMCI_WebServDataDesc.C ESMCI_WebServDataContent.C ESMCI_WebServDataMgr.C ESMCI_WebServClientInfo.C ESMCI_WebServCompSvrInfo.C ESMCI_WebServClientSocket.C ESMCI_WebServServerSocket.C ESMCI_WebServRegistrarClient.C ESMCI_WebServComponentSvr.C ESMCI_WebServCompSvrClient.C ESMCI_WebServSocketUtils.C ESMCI_WebServLowLevelSocket.C ESMCI_WebServCompSvrMgr.C ESMCI_WebServGRAMClient.C ESMCI_WebServForkClient.C ESMCI_WebServProcCtrl.C ESMCI_WebServProcCtrlClient.C ESMCI_WebServ_F.C)
target_sources(esmf PRIVATE ESMF_WebServ.F90 ESMF_WebServComponent_C.F90)
target_sources(esmf PRIVATE ../include/ESMCI_WebServ.h)
target_sources(esmf PUBLIC ../include/ESMCI_WebServLowLevelSocket.h ../include/ESMCI_WebServServerSocket.h ../include/ESMCI_WebServClientSocket.h ../include/ESMCI_WebServNetEsmf.h ../include/ESMCI_WebServNetEsmfClient.h ../include/ESMCI_WebServClientInfo.h ../include/ESMCI_WebServCompSvrClient.h ../include/ESMCI_WebServProcCtrlClient.h ../include/ESMCI_WebServProcCtrl.h ../include/ESMCI_WebServDataDesc.h ../include/ESMCI_WebServDataContent.h ../include/ESMCI_WebServCompSvrMgr.h)
