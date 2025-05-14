
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/prologue/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
add_subdirectory(tests)
if(ESMF_YAMLCPP STREQUAL internal)
  add_subdirectory(yaml-cpp)
endif()
