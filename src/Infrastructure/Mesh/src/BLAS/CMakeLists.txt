
if(${Git_FOUND})
    string(REGEX REPLACE "^([0-9]+)\.([0-9]+)(\.[0-9]+)?$" "\\1.\\2" ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
    add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
endif()
target_sources(esmf PRIVATE dcopy.F90 ddot.F90 dger.F90 dnrm2.F90 drot.F90 dscal.F90 dswap.F90 dtrmm.F90 dtrmv.F90 idamax.F90 dgemv.F90 dgemm.F90 dtrsm.F90 daxpy.F90 dsyr2k.F90 dsyr2.F90 dsymv.F90)
