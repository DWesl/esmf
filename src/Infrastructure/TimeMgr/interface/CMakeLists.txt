
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/Infrastructure/TimeMgr/interface/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE ESMCI_BaseTime_F.C ESMCI_Calendar_F.C ESMCI_TimeInterval_F.C ESMCI_Time_F.C ESMCI_Alarm_F.C ESMCI_Clock_F.C ESMC_Calendar.C ESMC_Time.C ESMC_TimeInterval.C ESMC_Clock.C)
target_sources(esmf PRIVATE ESMF_Calendar.F90 ESMF_TimeType.F90 ESMF_TimeIntervalType.F90 ESMF_Time.F90 ESMF_TimeInterval.F90 ESMF_AlarmType.F90 ESMF_ClockType.F90 ESMF_Alarm.F90 ESMF_Clock.F90)
target_sources(esmf PUBLIC ../include/ESMC_TimeInterval.h ../include/ESMC_Time.h ../include/ESMC_Calendar.h ../include/ESMC_Clock.h ../include/ESMF_TimeMgr.inc)
