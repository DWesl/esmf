cmake_minimum_required(VERSION 3.18)
project(ESMF VERSION 8.6.0 LANGUAGES Fortran CXX C DESCRIPTION "The Earth System Modeling Framework (ESMF) is a suite of software tools for developing high-performance, multi-component Earth science modeling applications."  HOMEPAGE_URL http://earthsystemmodeling.org )

# /build/common.mk
set(ESMF_DIR ${ESMF_SOURCE_DIR})

set(ESMF_BUILD ${ESMF_BINARY_DIR} CACHE FILEPATH "ESMF Build directory")

set(ESMF_OS default CACHE STRING "OS for ESMF build")
if(${CYGWIN})
  set(ESMF_OS Cygwin)
elseif(${APPLE})
  set(ESMF_OS Darwin)
elseif(${MINGW})
  set(ESMF_OS MinGW)
elseif(${LINUX})
  set(ESMF_OS Linux)
endif()

set(ESMF_MACHINE default CACHE STRING "ESMF build machine, from uname -m?")

# CMAKE_SYSTEM_PROCESSOR
set(ESMF_ABI default CACHE STRING "ABI for build")

set(ESMF_COMM mpiuni CACHE STRING "MPI implementation to use")
set_property(CACHE ESMF_COMM PROPERTY STRINGS mpiuni mpich1 mpich2 mpich lam msmpi openmpi user)
if(${ESMF_COMM} STREQUAL mpich3)
  set(ESMF_COMM mpich)
  message(WARNING For MPICH3+, use ESMF_COMM=mpich)
elseif(${ESMF_COMM} STREQUAL mvapich)
  set(ESMF_COMM mvapich)
  message(WARNING For MVAPICH2, use ESMF_COMM=mvapich)
endif()
if(NOT (${ESMF_COMM} STREQUAL mpiuni))
  find_package(MPI REQUIRED COMPONENTS Fortran C CXX)
  if(NOT ${MPI_Fortran_HAVE_F90_MODULE})
    message(SEND_ERROR "ESMF has use mpi statements")
  endif()
  include_directories(${MPI_Fortran_INCLUDE_DIRS} ${MPI_Fortran_INCLUDE_PATH})
  set(PIO_USE_MPISERIAL OFF)
else()
  # ESMF_COMM == mpiuni
  set(PIO_USE_MPIIO OFF)
  set(PIO_USE_MPISERIAL ON)
endif()

set(ESMF_COMPILER ${CMAKE_Fortran_COMPILER_ID})
# Possible values here:
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
if (${ESMF_COMPILER} STREQUAL GNU)
  set(ESMF_COMPILER gfortran)
  set(CMAKE_Fortran_FLAGS ${CMAKE_Fortran_FLAGS} -ffree-line-length-none)
endif()

include(FortranCInterface)
FortranCInterface_VERIFY()
FortranCInterface_VERIFY(CXX)
FortranCInterface_HEADER(ESMF_FortranFromC.h)

if(FortranCInterface_GLOBAL_CASE STREQUAL UPPER)
  message(SEND_ERROR "ESMF expects lower-case Fortran function names")
endif()
if(NOT ("${FortranCInterface_GLOBAL_PREFIX}" STREQUAL ""))
  message(SEND_ERROR "ESMF expects Fortran function names to be without prefix")
endif()

if(FortranCInterface_GLOBAL_SUFFIX STREQUAL _)
  add_compile_definitions(ESMF_LOWERCASE_SINGLEUNDERSCORE)
elseif(FortranCInterface_GLOBAL_SUFFIX STREQUAL __)
  add_compile_definitions(ESMF_LOWERCASE_DOUBLEUNDERSCORE)
else()
  message(SEND_ERROR "ESMF expects Fortran function names to end with one or two underscores")
endif()

# set(ESMF_FORTRANSYMBOLS default CACHE STRING "How to modify Fortran function names to call from C")
# set_property(CACHE ESMF_FORTRANSYMBOLS PROPERTY STRINGS default lowercase_singleunderscore lowercase_doubleunderscore)
# if(${ESMF_FORTRANSYMBOLS} STREQUAL lowercase_singleunderscore)
#   add_compile_definitions(ESMF_LOWERCASE_SINGLEUNDERSCORE)
#   if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
#     string(APPEND CMAKE_C_FLAGS " -fno-second-underscore")
#   endif()
# elseif(${ESMF_FORTRANSYMBOLS} STREQUAL lowercase_doubleunderscore)
#   add_compile_definitions(ESMF_LOWERCASE_DOUBLEUNDERSCORE)
#   if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
#     string(APPEND CMAKE_Fortran_FLAGS " -fsecond-underscore")
#   endif()
# endif()

set(ESMF_CPPDEFAULT gcc -E -P -x c -C -nostdinc)
set(CMAKE_CPP_COMPILER ${ESMF_CPPDEFAULT} CACHE STRING "C Preprocessor")

# CMAKE_BUILD_TYPE Debug Release RelWithDebInfo MinSizeRel
set(ESMF_BOPT O CACHE STRING "CMAKE_BUILD_TYPE")
set_property(CACHE ESMF_BOPT PROPERTY STRINGS g O)
# if(NOT ${ESMF_BOPT} STREQUAL g AND NOT ${ESMF_BOPT} STREQUAL O)
#   message(SEND_ERROR "Not a valid ESMF_BOPT setting")
# endif()

set(ESMF_OPTLEVEL default CACHE STRING "How much to optimize")
set(ESMF_SITE default CACHE STRING "ESMF_SITE, probably a directory?")

option(ESMF_PTHREADS "Use pthreads?" ON)
set(ESMF_PTHREADS ON CACHE BOOL "Use pthreads?")
if(${ESMF_PTHREADS})
  set(THREADS_PREFER_PTHREAD_FLAG ON)
  find_package(Threads REQUIRED)
else()
  add_compile_definitions(ESMF_NO_PTHREADS)
endif()

option(ESMF_OPENMP "Use openmp?" ON)
set(ESMF_OPENMP ON CACHE BOOL "Use openmp?")
if(ESMF_OPENMP)
  find_package(OpenMP REQUIRED COMPONENTS C CXX Fortran)
  # add_compile_definitions(_OPENMP)
  string(APPEND CMAKE_C_FLAGS " ${OpenMP_C_FLAGS}")
  string(APPEND CMAKE_Fortran_FLAGS " ${OpenMP_Fortran_FLAGS}")
  string(APPEND CMAKE_CXX_FLAGS " ${OpenMP_CXX_FLAGS}")
else()
  add_compile_definitions(ESMF_NO_OPENMP)
endif()

set(ESMF_ACC_SOFTWARE_STACK OFF CACHE STRING "Accelerator software stack to use")
set_property(CACHE ESMF_ACC_SOFTWARE_STACK PROPERTY STRINGS OFF opencl openacc intelmic openmp4)

if(ESMF_ACC_SOFTWARE_STACK STREQUAL openacc)
  find_package(OpenACC REQUIRED)
elseif(ESMF_ACC_SOFTWARE_STACK STREQUAL opencl)
  find_package(OpenCL REQUIRED)
elseif(ESMF_ACC_SOFTWARE_STACK STREQUAL openmp4)
  find_package(OpenMP 4.0 REQUIRED COMPONENTS C CXX Fortran)
endif()

option(ESMF_ARRAY_LITE "Use array lite?" OFF)
set(ESMF_ARRAY_LITE OFF CACHE BOOL "use array lite?")

# JSON CPP
include_directories(${ESMF_SOURCE_DIR}/src/Infrastructure/Base/include/nlohmann/json)

include(CheckTypeSize)
check_type_size(int8_t SIZEOF_INT8_T)
if(${SIZEOF_INT8_T} EQUAL 1)
  set(ESMF_NO_INTEGER_1_BYTE OFF CACHE BOOL "Does int8_t exist?")
else()
  set(ESMF_NO_INTEGER_1_BYTE ON CACHE BOOL "Does int8_t exist?")
endif()

check_type_size(int16_t SIZEOF_INT16_T)
if(${SIZEOF_INT16_T} EQUAL 2)
  set(ESMF_NO_INTEGER_2_BYTE OFF CACHE BOOL "Does int16_t exist?")
else()
  set(ESMF_NO_INTEGER_2_BYTE ON CACHE BOOL "Does int16_t exist?")
endif()

set(ESMF_LAPACK internal CACHE STRING "Lapack library to use")
set_property(CACHE ESMF_LAPACK PROPERTY STRINGS internal OFF system mkl netlib scsl openblas environment)
if(ESMF_LAPACK STREQUAL mkl)
  # MKL v10 has single- and multi-threaded LP64 and ILP64 versions
  # I'm going with the old version
  set(BLA_VENDOR Intel)
elseif(ESMF_LAPACK STREQUAL netlib)
  set(BLA_VENDOR Generic)
elseif(ESMF_LAPACK STREQUAL scsl)
  # Since ESMF has its own threading, I assume SCSL_mp would cause problems
  set(BLA_VENDOR SCSL)
elseif(ESMF_LAPACK STREQUAL openblas)
  set(BLA_VENDOR openblas)
endif()

if(NOT (ESMF_LAPACK STREQUAL OFF))
  find_package(LAPACK REQUIRED)
  add_compile_definitions(MOAB_HAVE_LAPACK)
endif()

option(ESMF_MAPPER_BUILD "Build mapper code? (requires lapacke)" OFF)
set(ESMF_MAPPER_BUILD OFF CACHE BOOL "Build mapper code? (requires lapacke)")
if(ESMF_MAPPER_BUILD)
  find_package(LAPACK REQUIRED)
endif()
set(ESMF_AUTO_LIB_BUILD ON CACHE BOOL "")

option(ESMF_DEFER_LIB_BUILD "Create library once at end, or update after every file?")
set(ESMF_DEFER_LIB_BUILD ON CACHE BOOL "Create library once at end, or update every step?")

set(ESMF_SHARED_LIB_BUILD ${BUILD_SHARED_LIBS})

set(ESMF_TRACE_LIB_BUILD ON CACHE BOOL "")
set(ESMF_TRACE_PRELOAD_LINKED OFF CACHE BOOL "")

set(ESMF_TESTEXHAUSTIVE OFF CACHE BOOL "Run all tests?")

set(ESMF_TESTPERFORMANCE ON CACHE BOOL "Run performance tests?")
set(ESMF_TESTCOMPTUNNEL ON CACHE BOOL "Run comp tunnel tests?")
set(ESMF_TESTWITHPTHREADS OFF CACHE BOOL "Run pthreads tests?")
set(ESMF_TEST_MPMD OFF CACHE BOOL "Run MPMD tests?")
set(ESMF_TESTSHAREDOBJ OFF CACHE BOOL "Test shared objects?")
set(ESMF_TESTFORCEOPENACC OFF CACHE BOOL "Test forcinc OpenACC?")

set(ESMF_MOAB internal CACHE STRING "Which MOAB build to use")
set_property(CACHE ESMF_MOAB PROPERTY STRINGS internal OFF external)


set(ESMF_YAMLCPP internal CACHE STRING "Which YAMLCPP build to use")
set_property(CACHE ESMF_YAMLCPP PROPERTY STRINGS OFF internal standard environment)
if(${ESMF_YAMLCPP} STREQUAL standard)
  find_package(yaml REQUIRED)
endif()
if(NOT (${ESMF_YAMLCPP} STREQUAL OFF))
  add_compile_definitions(ESMF_YAMLCPP)
endif()

set(ESMF_PIO internal CACHE STRING "Which PIO build to use")
set_property(CACHE ESMF_PIO PROPERTY STRINGS internal system)
if(${ESMF_PIO} STREQUAL system)
  find_package(PIO REQUIRED)
else()
  add_subdirectory(src/Infrastructure/IO/PIO/ParallelIO)
  include_directories(${ESMF_BUILD}/src/Infrastructure/IO/PIO/ParallelIO/src/clib)
endif()

set(ESMF_ARCREATEFLAGSDEFAULT cr)


# ...

# find_package(LATEX COMPONENTS LATEX2HTML)

if(${ESMF_ARRAY_LITE})
  string(APPEND CMAKE_C_FLAGS -DESMF_NO_GREATER_THAN_4D)
endif()
if(${ESMF_NO_INTEGER_1_BYTE})
  # string(APPEND CMAKE_C_FLAGS -DESMF_NO_INTEGER_1_BYTE)
  add_compile_definitions(ESMF_NO_INTEGER_1_BYTE)
endif()
if(${ESMF_NO_INTEGER_2_BYTE})
  # string(APPEND CMAKE_C_FLAGS -DESMF_NO_INTEGER_2_BYTE)
  add_compile_definitions(ESMF_NO_INTEGER_2_BYTE)
endif()

find_package(Git)
if(Git_FOUND)
  message("Git executable: ${GIT_EXECUTABLE}")
  message("Git version: ${GIT_VERSION_STRING}")
  # string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2"
  #              ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
  set(ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
  message("ESMF GIT VERSION ${ESMF_VERSION_STRING_GIT}")
  add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()

set(ESMF_SED sed CACHE STRING "Path to sed")

set(ESMF_PIODEFAULT internal)
set(ESMF_PROJ4DEFAULT OFF)
set(ESMF_PTHREADSDEFAULT OFF)

# ESMF_CXXSTD
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_C_STANDARD 99)

## build_config/*/build_rules.mk
if(${CYGWIN})
  add_compile_definitions(_BSD_SOURCE _POSIX_C_COURCE=199309L _GNU_SOURCE)
endif()

set(ESMF_NETCDF OFF CACHE STRING "NetCDF configuration")
set_property(CACHE ESMF_NETCDF PROPERTY STRINGS OFF nc-config split standard environment)
if(NOT (${ESMF_NETCDF} STREQUAL OFF))
  execute_process(COMMAND ${ESMF_SOURCE_DIR}/scripts/pathtype ${ESMF_NETCDF} RESULT_VARIABLE pathtype)
endif()

set(ESMF_PNETCDF OFF CACHE STRING "pNetCDF configuration")
set_property(CACHE ESMF_PNETCDF PROPERTY STRINGS OFF pnetcdf-config standard environment)
if(${ESMF_PNETCDF})
  # PIO option
  set(WITH_PNETCDF ON)
else()
  set(WITH_PNETCDF OFF)
endif()

set(ESMF_XERCES OFF CACHE STRING "Use Xerces C++ XML library?")
set_property(CACHE ESMF_XERCES PROPERTY STRINGS OFF standard environment)

add_library(esmf)
if(ESMF_OPENMP)
  target_link_libraries(esmf OpenMP::OpenMP_Fortran)
endif()

if(NOT (ESMF_PIO STREQUAL OFF))
  if(ESMF_PIO STREQUAL internal)
    target_link_libraries(esmf piof)
  else()
    target_link_libraries(esmf PIO::piof)
  endif()
endif()

if(ESMF_PNETCDF STREQUAL standard)
  target_link_libraries(esmf pnetcdf)
endif()
if(ESMF_NETCDF STREQUAL split)
  target_link_libraries(esmf netcdff netcdf)
elseif(ESMF_NETCDF STREQUAL standard)
  target_link_libraries(esmf netcdf)
endif()
if(ESMF_ACC_SOFTWARE_STACK STREQUAL openmp4)
  target_link_libraries(esmf OpenMP::OpenMP_Fortran)
elseif(ESMF_ACC_SOFTWARE_STACK STREQUAL openacc)
  target_link_libraries(esmf OpenACC::OpenACC_Fortran)
elseif(ESMF_ACC_SOFTWARE_STACK STREQUAL opencl)
  target_link_libraries(esmf OpenCL::OpenCL)
endif()
if(NOT (${ESMF_COMM} STREQUAL mpiuni))
  target_link_libraries(esmf MPI::MPI_Fortran)
endif()
if(NOT (ESMF_LAPACK STREQUAL OFF))
  target_link_libraries(esmf LAPACK::LAPACK BLAS::BLAS)
endif()

# install(PUBLIC_HEADER DESTINATION INCLUDE)
install(FILES ${ESMF_BINARY_DIRECTORY}/src/include/NUOPC.h ${ESMF_BINARY_DIRECTORY}/src/include/ESMC.h ${ESMF_BINARY_DIRECTORY}/src/include/ESMC_*.h TYPE INCLUDE)
install(FILES ${ESMF_SOURCE_DIR}/build_config/${ESMF_OS}.${ESMF_COMPILER}.${ESMF_SITE}/ESMC_Conf.h TYPE INCLUDE)
# TODO: install(FILES ${ESMF_ESMXDIR} TYPE INCLUDE)

install(TARGETS esmf EXPORT ESMF)

set(ESMF_INCDIR ${ESMF_SOURCE_DIR}/src/Infrastructure/Util/include)

include_directories(
    ${ESMF_INCDIR}
    ${ESMF_SOURCE_DIR}/build_config/${ESMF_OS}.${ESMF_COMPILER}.${ESMF_SITE}
    ${ESMF_SOURCE_DIR}/src/addon/NUOPC/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Array/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/ArrayBundle/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/ArraySpec/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Base/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Config/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Container/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/DELayout/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/DistGrid/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Field/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Grid/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/GridUtil/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/IO/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/LocalArray/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/LocStream/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/LogErr/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Mesh/src/Moab
    ${ESMF_SOURCE_DIR}/src/Infrastructure/PointList/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Route/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/Trace/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/TimeMgr/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/VM/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/XGrid/include
    ${ESMF_SOURCE_DIR}/src/Infrastructure/stubs/pthread
    ${ESMF_SOURCE_DIR}/src/Superstructure/Component/include
    ${ESMF_SOURCE_DIR}/src/Superstructure/ESMFMod/include
    ${ESMF_SOURCE_DIR}/src/Superstructure/State/include
    ${ESMF_SOURCE_DIR}/src/Superstructure/WebServices/include
    ${ESMF_SOURCE_DIR}/src/epilogue/include)
set(CMAKE_Fortran_PREPROCESS ON)
if(ESMF_MAPPER_BUILD)
  include_directories(${ESMF_SOURCE_DIR}/src/Superstructure/Mapper/include)
endif()

configure_file(cppF90_to_F90.in cppF90_to_F90 @ONLY)

add_subdirectory(src)
