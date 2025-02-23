! $Id$
!
! Example/test code which shows User Component calls.

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

!
! !DESCRIPTION:
!  Land component with a single Field exported
!
!
!\begin{verbatim}

module land_comp

  ! ESMF Framework module
  use ESMF
  use util_mod

  implicit none
    
  public land_setvm, land_register
        
  contains

!-------------------------------------------------------------------------
!   !  The Register routine sets the subroutines to be called
!   !   as the init, run, and finalize routines.  Note that these are
!   !   private to the module.
 
  subroutine land_setvm(comp, rc)
    type(ESMF_GridComp) :: comp
    integer, intent(out) :: rc
#ifdef ESMF_TESTWITHTHREADS
    type(ESMF_VM) :: vm
    logical :: pthreadsEnabled
#endif

    ! Initialize return code
    rc = ESMF_SUCCESS

#ifdef ESMF_TESTWITHTHREADS
    ! The following call will turn on ESMF-threading (single threaded)
    ! for this component. If you are using this file as a template for
    ! your own code development you probably don't want to include the
    ! following call unless you are interested in exploring ESMF's
    ! threading features.

    ! First test whether ESMF-threading is supported on this machine
    call ESMF_VMGetGlobal(vm, rc=rc)
    call ESMF_VMGet(vm, pthreadsEnabledFlag=pthreadsEnabled, rc=rc)
    if (pthreadsEnabled) then
      call ESMF_GridCompSetVMMinThreads(comp, rc=rc)
    endif
#endif

  end subroutine

  subroutine land_register(comp, rc)
    type(ESMF_GridComp) :: comp
    integer, intent(out) :: rc

    ! Initialize return code
    rc = ESMF_SUCCESS

    print *, "Land Register starting"

    ! Register the callback routines.

    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_INITIALIZE, userRoutine=land_init, &
      rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_RUN, userRoutine=land_run, &
      rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_FINALIZE, userRoutine=land_final, &
      rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out

    print *, "Registered Initialize, Run, and Finalize routines"
    print *, "Land Register returning"
    
  end subroutine

!-------------------------------------------------------------------------
!   !  User Comp Component created by higher level calls, here is the
!   !   Initialization routine.
 
    
  subroutine land_init(comp, importState, exportState, clock, rc)
    type(ESMF_GridComp) :: comp
    type(ESMF_State) :: importState, exportState
    type(ESMF_Clock) :: clock
    integer, intent(out) :: rc

    ! Local variables
    type(ESMF_ArraySpec)  :: arrayspec
    type(ESMF_DistGrid)   :: distgrid
    type(ESMF_Grid)       :: grid
    type(ESMF_Field)      :: field
    type(ESMF_VM)         :: vm
    integer               :: petCount, localPet
    
    ! Initialize return code
    rc = ESMF_SUCCESS

    ! Determine petCount
    call ESMF_GridCompGet(comp, vm=vm, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_VMGet(vm, petCount=petCount, localPet=localPet, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    print *, "Land Init starting, localPet =", localPet
    
    ! Create the source Field and add it to the export State
    call ESMF_ArraySpecSet(arrayspec, typekind=ESMF_TYPEKIND_R8, rank=2, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    !
    grid = make_grid_sph(45,120,8.,1.5,0.,-90., msx=200., mex=360., msy=-90., mey=90., &
          maskvalue=4, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    !
    field = ESMF_FieldCreate(arrayspec=arrayspec, grid=grid, &
      indexflag=ESMF_INDEX_GLOBAL, name="F_lnd", rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_StateAdd(exportState, (/field/), rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out

    call ESMF_StatePrint(exportState, rc=rc)
   
    print *, "land Init returning"

  end subroutine land_init


!-------------------------------------------------------------------------
!   !  The Run routine where data is computed.
!   !
 
  subroutine land_run(comp, importState, exportState, clock, rc)
    type(ESMF_GridComp) :: comp
    type(ESMF_State) :: importState, exportState
    type(ESMF_Clock) :: clock
    integer, intent(out) :: rc

    ! Local variables
    real(ESMF_KIND_R8)    :: pi, kx, ky
    type(ESMF_Field)      :: field
    real(ESMF_KIND_R8), pointer :: farrayPtr(:,:)   ! matching F90 array pointer
    integer               :: i, j, elb(2), eub(2)
    
    ! Initialize return code
    rc = ESMF_SUCCESS

    print *, "Land Run starting"

    pi = 3.14159d0

    ! Get the source Field from the export State
    call ESMF_StateGet(exportState, "F_lnd", field, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out

    ! Gain access to actual data via F90 array pointer
    call ESMF_FieldGet(field, localDe=0, farrayPtr=farrayPtr, &
      exclusiveLBound=elb, exclusiveUBound=eub, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out

    ! Fill source Field with data
    kx = 2.*pi/(eub(1)-elb(1))
    ky = 2.*pi/(eub(2)-elb(2))
    do i = elb(1), eub(1)
      do j = elb(2), eub(2)
        farrayPtr(i,j) = cos(kx*i)*sin(ky*j)
      enddo
    enddo
 
    print *, "Land Run returning"

  end subroutine land_run


!-------------------------------------------------------------------------
!   !  The Finalization routine where things are deleted and cleaned up.
!   !
 
  subroutine land_final(comp, importState, exportState, clock, rc)
    type(ESMF_GridComp) :: comp
    type(ESMF_State) :: importState, exportState
    type(ESMF_Clock) :: clock
    integer, intent(out) :: rc

    ! Local variables
    type(ESMF_Grid) :: grid
    type(ESMF_Field) :: field
    
    ! Initialize return code
    rc = ESMF_SUCCESS

    print *, "Land Final starting"

    call ESMF_StateGet(exportState, "F_lnd", field, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_FieldGet(field, grid=grid, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_FieldDestroy(field, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out
    call ESMF_GridDestroy(grid, rc=rc)
    if (rc/=ESMF_SUCCESS) return ! bail out

    print *, "Land Final returning"

  end subroutine land_final


end module land_comp
    
!\end{verbatim}
