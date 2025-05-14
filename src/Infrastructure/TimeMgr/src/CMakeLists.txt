
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/TimeMgr/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_BaseTime.C ESMCI_TimeInterval.C ESMCI_Time.C ESMCI_Calendar.C ESMCI_Alarm.C ESMCI_Clock.C)
target_sources(esmf PUBLIC ../include/ESMCI_BaseTime.h ../include/ESMCI_TimeInterval.h ../include/ESMCI_Time.h ../include/ESMCI_Calendar.h ../include/ESMCI_Alarm.h ../include/ESMCI_Clock.h)
