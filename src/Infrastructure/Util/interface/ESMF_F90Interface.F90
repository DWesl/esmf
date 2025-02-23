! $Id$
!
! Earth System Modeling Framework
! Copyright (c) 2002-2023, University Corporation for Atmospheric Research,
! Massachusetts Institute of Technology, Geophysical Fluid Dynamics
! Laboratory, University of Michigan, National Centers for Environmental
! Prediction, Los Alamos National Laboratory, Argonne National Laboratory,
! NASA Goddard Space Flight Center.
! Licensed under the University of Illinois-NCSA License.
!
!==============================================================================
#define ESMF_FILENAME "ESMF_F90Interface.F90"
!==============================================================================
!
! ESMF DistGrid Module
module ESMF_F90InterfaceMod
!
!==============================================================================
!
! This file contains helper methods for the F90-to-C++ and C++-to-F90 interface
!
!------------------------------------------------------------------------------
! INCLUDES
#include "ESMF.h"

! !USES:
  use ESMF_UtilTypesMod     ! ESMF utility types
  use ESMF_LogErrMod        ! ESMF error handling

!------------------------------------------------------------------------------
! !PRIVATE TYPES:
  private

  public ESMF_InterArray
  public ESMF_InterArrayCreate
  public ESMF_InterArrayGet
  public ESMF_InterArrayDestroy

!------------------------------------------------------------------------------
! ESMF_InterArray:
!   Handling of [optional] integer arrays on the Fortran-to-C++ interface.
!
!------------------------------------------------------------------------------

  ! F90 class type to hold pointer to C++ object
  type ESMF_InterArray
#ifndef ESMF_NO_SEQUENCE
  sequence
#endif
  private
    ! The 10 x 64-bit = 640-bit memory block in shallowMemory is used on the
    ! C++ implementation side to store the C pointers and meta-data.
    ! Keeping this memory as shallow on the stack eliminates the need for
    ! complicated garbage collection around heap memory.
#ifndef ESMF_NO_INITIALIZERS
    integer(ESMF_KIND_I8), dimension(10) :: shallowMemory = 0
#else
    integer(ESMF_KIND_I8), dimension(10) :: shallowMemory
#endif
    integer, pointer   :: farray1D(:)       ! Fortran reference
    integer, pointer   :: farray2D(:,:)     ! Fortran reference
    integer, pointer   :: farray3D(:,:,:)   ! Fortran reference
    integer(ESMF_KIND_I8), pointer :: farray1DI8(:)       ! Fortran reference
    integer(ESMF_KIND_I8), pointer :: farray2DI8(:,:)     ! Fortran reference
    integer(ESMF_KIND_I8), pointer :: farray3DI8(:,:,:)   ! Fortran reference
    real(ESMF_KIND_R8), pointer :: farray1DR8(:)       ! Fortran reference
    real(ESMF_KIND_R8), pointer :: farray2DR8(:,:)     ! Fortran reference
    real(ESMF_KIND_R8), pointer :: farray3DR8(:,:,:)   ! Fortran reference
    logical   :: owner    ! flag need for deallocation during Destroy()

  end type


!==============================================================================
!
! INTERFACE BLOCKS
!
!==============================================================================

! -------------------------- ESMF-public method -------------------------------
!BOPI
! !IROUTINE: ESMF_InterArrayCreate -- Generic interface

! !INTERFACE:
  interface ESMF_InterArrayCreate

! !PRIVATE MEMBER FUNCTIONS:
!
    module procedure ESMF_InterArrayCreateTrg
    module procedure ESMF_InterArrayCreatePtr

! !DESCRIPTION:
!EOPI
  end interface
!==============================================================================


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

contains

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_InterArrayCreateTrg()"
!BOPI
! !IROUTINE: ESMF_InterArrayCreateTrg - Create InterArray

! !INTERFACE:
  recursive function ESMF_InterArrayCreateTrg(farray1D, farray2D, farray3D, &
    farray1DI8, farray2DI8, farray3DI8, farray1DR8, farray2DR8, farray3DR8, &
    rc) result (InterArrayCreateTrg)
!
! !ARGUMENTS:
    integer, target,               intent(in),  optional :: farray1D(:)
    integer, target,               intent(in),  optional :: farray2D(:,:)
    integer, target,               intent(in),  optional :: farray3D(:,:,:)
    integer(ESMF_KIND_I8), target, intent(in),  optional :: farray1DI8(:)
    integer(ESMF_KIND_I8), target, intent(in),  optional :: farray2DI8(:,:)
    integer(ESMF_KIND_I8), target, intent(in),  optional :: farray3DI8(:,:,:)
    real(ESMF_KIND_R8), target,    intent(in),  optional :: farray1DR8(:)
    real(ESMF_KIND_R8), target,    intent(in),  optional :: farray2DR8(:,:)
    real(ESMF_KIND_R8), target,    intent(in),  optional :: farray3DR8(:,:,:)
    integer,                       intent(out), optional :: rc
!
! !RETURN VALUE:
    type(ESMF_InterArray) :: InterArrayCreateTrg
!
! !DESCRIPTION:
!   Create an {\tt ESMF\_InterArray} from Fortran array.
!
!   The arguments are:
!   \begin{description}
!   \item[{[farray1D]}]
!     1D Fortran array of default integer kind.
!   \item[{[farray2D]}]
!     2D Fortran array of default integer kind.
!   \item[{[farray3D]}]
!     3D Fortran array of default integer kind.
!   \item[{[farray1DI8]}]
!     1D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray2DI8]}]
!     2D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray3DI8]}]
!     3D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray1DR8]}]
!     1D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[farray2DR8]}]
!     2D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[farray3DR8]}]
!     3D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[rc]}]
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    type(ESMF_InterArray)   :: array        ! opaque pointer to new C++ object
    integer, pointer        :: farray1DPtr(:)
    integer, pointer        :: farray2DPtr(:,:)
    integer, pointer        :: farray3DPtr(:,:,:)
    integer(ESMF_KIND_I8), pointer        :: farray1DI8Ptr(:)
    integer(ESMF_KIND_I8), pointer        :: farray2DI8Ptr(:,:)
    integer(ESMF_KIND_I8), pointer        :: farray3DI8Ptr(:,:,:)
    real(ESMF_KIND_R8), pointer           :: farray1DR8Ptr(:)
    real(ESMF_KIND_R8), pointer           :: farray2DR8Ptr(:,:)
    real(ESMF_KIND_R8), pointer           :: farray3DR8Ptr(:,:,:)

    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL

    ! mark this InterArray as invalid
    call c_ESMC_InterArraySetInvalid(array, localrc)
    InterArrayCreateTrg = array
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return

    ! initialize
    nullify(farray1DPtr)
    nullify(farray2DPtr)
    nullify(farray3DPtr)
    nullify(farray1DI8Ptr)
    nullify(farray2DI8Ptr)
    nullify(farray3DI8Ptr)
    nullify(farray1DR8Ptr)
    nullify(farray2DR8Ptr)
    nullify(farray3DR8Ptr)

    if (present(farray1D)) farray1DPtr => farray1D
    if (present(farray2D)) farray2DPtr => farray2D
    if (present(farray3D)) farray3DPtr => farray3D
    if (present(farray1DI8)) farray1DI8Ptr => farray1DI8
    if (present(farray2DI8)) farray2DI8Ptr => farray2DI8
    if (present(farray3DI8)) farray3DI8Ptr => farray3DI8
    if (present(farray1DR8)) farray1DR8Ptr => farray1DR8
    if (present(farray2DR8)) farray2DR8Ptr => farray2DR8
    if (present(farray3DR8)) farray3DR8Ptr => farray3DR8

    ! create InterArray object
    array = ESMF_InterArrayCreate(farray1DPtr, farray2DPtr, farray3DPtr, &
      farray1DI8Ptr, farray2DI8Ptr, farray3DI8Ptr,  &
      farray1DR8Ptr, farray2DR8Ptr, farray3DR8Ptr,  &
      transferOwnership=.false., rc=localrc)
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return

    ! set return value
    InterArrayCreateTrg = array

    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS

  end function ESMF_InterArrayCreateTrg
!------------------------------------------------------------------------------


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_InterArrayCreatePtr()"
!BOPI
! !IROUTINE: ESMF_InterArrayCreatePtr - Create InterArray

! !INTERFACE:
  recursive function ESMF_InterArrayCreatePtr(farray1D, farray2D, farray3D, &
       farray1DI8, farray2DI8, farray3DI8, &
       farray1DR8, farray2DR8, farray3DR8, &
       transferOwnership, rc) &
       result (InterArrayCreatePtr)
!
! !ARGUMENTS:
    integer, pointer,                   optional :: farray1D(:)
    integer, pointer,                   optional :: farray2D(:,:)
    integer, pointer,                   optional :: farray3D(:,:,:)
    integer(ESMF_KIND_I8), pointer,     optional :: farray1DI8(:)
    integer(ESMF_KIND_I8), pointer,     optional :: farray2DI8(:,:)
    integer(ESMF_KIND_I8), pointer,     optional :: farray3DI8(:,:,:)
    real(ESMF_KIND_R8), pointer,        optional :: farray1DR8(:)
    real(ESMF_KIND_R8), pointer,        optional :: farray2DR8(:,:)
    real(ESMF_KIND_R8), pointer,        optional :: farray3DR8(:,:,:)
    logical,               intent(in)            :: transferOwnership
    integer,               intent(out), optional :: rc
!
! !RETURN VALUE:
    type(ESMF_InterArray) :: InterArrayCreatePtr
!
! !DESCRIPTION:
!   Create an {\tt ESMF\_InterArray} from Fortran array. The
!   {\tt transferOwnership} allows ownership of the Fortran array to be
!   transferred to the InterArray object. InterArrayDestroy() will call
!   deallocate() for Fortran arrays whose ownership was transferred.
!
!   The arguments are:
!   \begin{description}
!   \item[{[farray1D]}]
!     1D Fortran array of default integer kind.
!   \item[{[farray2D]}]
!     2D Fortran array of default integer kind.
!   \item[{[farray3D]}]
!     3D Fortran array of default integer kind.
!   \item[{[farray1DI8]}]
!     1D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray2DI8]}]
!     2D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray3DI8]}]
!     3D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray1DR8]}]
!     1D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[farray2DR8]}]
!     2D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[farray3DR8]}]
!     3D Fortran array of ESMF_TYPEKIND_R8.
!   \item[transferOwnership]
!     For a value of {\tt .true.} transfers ownership of Fortran array to the
!     newly created InterArray object.
!   \item[{[rc]}]
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    type(ESMF_InterArray)   :: array        ! opaque pointer to new C++ object
    integer, allocatable    :: len(:)
    integer                 :: checkCount
    integer(ESMF_KIND_I8)   :: dummyI8
    real(ESMF_KIND_R8)      :: dummyR8

    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL

    ! mark this InterArray as invalid
    call c_ESMC_InterArraySetInvalid(array, localrc)
    InterArrayCreatePtr = array
    if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
      ESMF_CONTEXT, rcToReturn=rc)) return

    ! initialize Fortran array references
    nullify(array%farray1D)
    nullify(array%farray2D)
    nullify(array%farray3D)
    nullify(array%farray1DI8)
    nullify(array%farray2DI8)
    nullify(array%farray3DI8)
    nullify(array%farray1DR8)
    nullify(array%farray2DR8)
    nullify(array%farray3DR8)

    ! check that only one of the array arguments is present
    checkCount = 0  ! reset
    if (present(farray1D)) then
      if (associated(farray1D)) checkCount = checkCount + 1
    endif
    if (present(farray2D)) then
      if (associated(farray2D)) checkCount = checkCount + 1
    endif
    if (present(farray3D)) then
      if (associated(farray3D)) checkCount = checkCount + 1
    endif
    if (present(farray1DI8)) then
      if (associated(farray1DI8)) checkCount = checkCount + 1
    endif
    if (present(farray2DI8)) then
      if (associated(farray2DI8)) checkCount = checkCount + 1
    endif
    if (present(farray3DI8)) then
      if (associated(farray3DI8)) checkCount = checkCount + 1
    endif
    if (present(farray1DR8)) then
      if (associated(farray1DR8)) checkCount = checkCount + 1
    endif
    if (present(farray2DR8)) then
      if (associated(farray2DR8)) checkCount = checkCount + 1
    endif
    if (present(farray3DR8)) then
      if (associated(farray3DR8)) checkCount = checkCount + 1
    endif
    if (checkCount>1) then
      call ESMF_LogSetError(rcToCheck=ESMF_RC_ARG_BAD, &
        msg="too many farrayXD arguments were specified.", &
        ESMF_CONTEXT, rcToReturn=rc)
      return
    endif

    ! set owner flag
    array%owner = transferOwnership

    ! call into the C++ interface, depending on whether or not farray is present
    if (present(farray1D)) then
      if (associated(farray1D)) then
        array%farray1D => farray1D
        allocate(len(1))
        len = shape(farray1D)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate1D(array, farray1D(1), len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate1D(array, 0, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray2D)) then
      if (associated(farray2D)) then
        array%farray2D => farray2D
        allocate(len(2))
        len = shape(farray2D)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate2D(array, farray2D(1,1), len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate2D(array, 0, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray3D)) then
      if (associated(farray3D)) then
        array%farray3D => farray3D
        allocate(len(3))
        len = shape(farray3D)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate3D(array, farray3D(1,1,1), len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate3D(array, 0, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray1DI8)) then
      if (associated(farray1DI8)) then
        array%farray1DI8 => farray1DI8
        allocate(len(1))
        len = shape(farray1DI8)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate1DI8(array, farray1DI8(1), len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate1DI8(array, dummyI8, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray2DI8)) then
      if (associated(farray2DI8)) then
        array%farray2DI8 => farray2DI8
        allocate(len(2))
        len = shape(farray2DI8)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate2DI8(array, farray2DI8(1,1), len, &
            localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate2DI8(array, dummyI8, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray3DI8)) then
      if (associated(farray3DI8)) then
        array%farray3DI8 => farray3DI8
        allocate(len(3))
        len = shape(farray3DI8)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate3DI8(array, farray3DI8(1,1,1), len, &
            localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate3DI8(array, dummyI8, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif

    if (present(farray1DR8)) then
      if (associated(farray1DR8)) then
        array%farray1DR8 => farray1DR8
        allocate(len(1))
        len = shape(farray1DR8)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate1DR8(array, farray1DR8(1), len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate1DR8(array, dummyR8, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray2DR8)) then
      if (associated(farray2DR8)) then
        array%farray2DR8 => farray2DR8
        allocate(len(2))
        len = shape(farray2DR8)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate2DR8(array, farray2DR8(1,1), len, &
            localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate2DR8(array, dummyR8, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif
    if (present(farray3DR8)) then
      if (associated(farray3DR8)) then
        array%farray3DR8 => farray3DR8
        allocate(len(3))
        len = shape(farray3DR8)
        if (all(len .ne. 0)) then
          call c_ESMC_InterArrayCreate3DR8(array, farray3DR8(1,1,1), len, &
            localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        else
          call c_ESMC_InterArrayCreate3DR8(array, dummyR8, len, localrc)
          if (ESMF_LogFoundError(localrc, ESMF_ERR_PASSTHRU, &
            ESMF_CONTEXT, rcToReturn=rc)) return
        endif
        deallocate(len)
      endif
    endif

    ! set return value
    InterArrayCreatePtr = array

    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS

  end function ESMF_InterArrayCreatePtr
!------------------------------------------------------------------------------


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_InterArrayGet()"
!BOPI
! !IROUTINE: ESMF_InterArrayGet - Get array pointer out of InterArray

! !INTERFACE:
  recursive subroutine ESMF_InterArrayGet(array, farray1D, farray2D, farray3D, &
    farray1DI8, farray2DI8, farray3DI8, farray1DR8, farray2DR8, farray3DR8, rc)
!
! !ARGUMENTS:
    type(ESMF_InterArray), intent(in)              :: array
    integer,                 pointer,     optional :: farray1D(:)
    integer,                 pointer,     optional :: farray2D(:,:)
    integer,                 pointer,     optional :: farray3D(:,:,:)
    integer(ESMF_KIND_I8),   pointer,     optional :: farray1DI8(:)
    integer(ESMF_KIND_I8),   pointer,     optional :: farray2DI8(:,:)
    integer(ESMF_KIND_I8),   pointer,     optional :: farray3DI8(:,:,:)
    real(ESMF_KIND_R8),      pointer,     optional :: farray1DR8(:)
    real(ESMF_KIND_R8),      pointer,     optional :: farray2DR8(:,:)
    real(ESMF_KIND_R8),      pointer,     optional :: farray3DR8(:,:,:)
    integer,                 intent(out), optional :: rc
!
!
! !DESCRIPTION:
!   Get pointer out of an {\tt ESMF\_InterArray} object.
!
!   The arguments are:
!   \begin{description}
!   \item[array]
!     {\tt ESMF\_InterArray} object.
!   \item[{[farray1D]}]
!     1D Fortran array of default integer kind.
!   \item[{[farray2D]}]
!     2D Fortran array of default integer kind.
!   \item[{[farray3D]}]
!     3D Fortran array of default integer kind.
!   \item[{[farray1DI8]}]
!     1D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray2DI8]}]
!     2D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray3DI8]}]
!     3D Fortran array of ESMF_TYPEKIND_I8.
!   \item[{[farray1DR8]}]
!     1D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[farray2DR8]}]
!     2D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[farray3DR8]}]
!     3D Fortran array of ESMF_TYPEKIND_R8.
!   \item[{[rc]}]
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    integer                 :: stat         ! Fortran return code

    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL

    if (present(farray1D)) farray1D => array%farray1D
    if (present(farray2D)) farray2D => array%farray2D
    if (present(farray3D)) farray3D => array%farray3D
    if (present(farray1DI8)) farray1DI8 => array%farray1DI8
    if (present(farray2DI8)) farray2DI8 => array%farray2DI8
    if (present(farray3DI8)) farray3DI8 => array%farray3DI8
    if (present(farray1DR8)) farray1DR8 => array%farray1DR8
    if (present(farray2DR8)) farray2DR8 => array%farray2DR8
    if (present(farray3DR8)) farray3DR8 => array%farray3DR8

    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS

  end subroutine ESMF_InterArrayGet
!------------------------------------------------------------------------------


! -------------------------- ESMF-public method -------------------------------
#undef  ESMF_METHOD
#define ESMF_METHOD "ESMF_InterArrayDestroy()"
!BOPI
! !IROUTINE: ESMF_InterArrayDestroy - Destroy InterArray

! !INTERFACE:
  recursive subroutine ESMF_InterArrayDestroy(array, rc)
!
! !ARGUMENTS:
    type(ESMF_InterArray), intent(inout)         :: array
    integer,                 intent(out), optional :: rc
!
!
! !DESCRIPTION:
!   Destroy an {\tt ESMF\_InterArray} object. Deallocate Fortran arrays
!   whose ownership was transferred to the InterArray object.
!
!   The arguments are:
!   \begin{description}
!   \item[array]
!     {\tt ESMF\_InterArray} object.
!   \item[{[rc]}]
!     Return code; equals {\tt ESMF\_SUCCESS} if there are no errors.
!   \end{description}
!
!EOPI
!------------------------------------------------------------------------------
    integer                 :: localrc      ! local return code
    integer                 :: stat         ! Fortran return code

    ! initialize return code; assume routine not implemented
    localrc = ESMF_RC_NOT_IMPL
    if (present(rc)) rc = ESMF_RC_NOT_IMPL

    ! deallocate Fortran arrays if ownership was transferred
    if (array%owner) then
      if (associated(array%farray1D)) then
        deallocate(array%farray1D, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray1D", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray2D)) then
        deallocate(array%farray2D, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray2D", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray3D)) then
        deallocate(array%farray3D, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray3D", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray1DI8)) then
        deallocate(array%farray1DI8, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray1DI8", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray2DI8)) then
        deallocate(array%farray2DI8, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray2DI8", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray3DI8)) then
        deallocate(array%farray3DI8, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray3DI8", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif

      if (associated(array%farray1DR8)) then
        deallocate(array%farray1DR8, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray1DR8", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray2DR8)) then
        deallocate(array%farray2DR8, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray2DR8", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
      if (associated(array%farray3DR8)) then
        deallocate(array%farray3DR8, stat=stat)
        if (ESMF_LogFoundDeallocError(stat, msg="deallocating array%farray3DR8", &
          ESMF_CONTEXT)) &
          return  ! bail out
      endif
    endif

    ! return successfully
    if (present(rc)) rc = ESMF_SUCCESS

  end subroutine ESMF_InterArrayDestroy
!------------------------------------------------------------------------------


end module ESMF_F90InterfaceMod
