
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/apps/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_subdirectory(ESMF_Scrip2Unstruct)
add_subdirectory(ESMF_RegridWeightGen)
add_subdirectory(ESMF_WebServController)
add_subdirectory(ESMF_PrintInfo)
add_subdirectory(ESMX_Builder)
add_subdirectory(ESMF_PrintInfoC)
add_subdirectory(ESMF_Regrid)
