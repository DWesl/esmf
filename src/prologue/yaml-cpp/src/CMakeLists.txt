
target_include_directories(esmf PRIVATE ${ESMF_SOURCE_DIR}/src/prologue/yaml-cpp/src/../include)

if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE binary.cpp emitterutils.cpp nodeevents.cpp scanscalar.cpp convert.cpp exceptions.cpp null.cpp scantag.cpp directives.cpp depthguard.cpp exp.cpp ostream_wrapper.cpp scantoken.cpp emit.cpp memory.cpp parse.cpp simplekey.cpp emitfromevents.cpp nodebuilder.cpp parser.cpp singledocparser.cpp emitter.cpp node.cpp regex_yaml.cpp stream.cpp emitterstate.cpp node_data.cpp scanner.cpp tag.cpp)
