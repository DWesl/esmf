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
!
      program ESMF_VMSendRecvNbUTest

!------------------------------------------------------------------------------
 
#include "ESMF_Macros.inc"

!==============================================================================
!BOP
! !PROGRAM: ESMF_VMSendRecvNbUTest - Unit test for non-blocking VM SendRecv
!  Function
!
! !DESCRIPTION:
!
! The code in this file drives the F90 non-blocking VM SendRecv tests.  The VM
!   SendRecv function is complex enough to require a separate test file.
!   It runs on multiple processors.
!
!-----------------------------------------------------------------------------
! !USES:
      use ESMF_TestMod     ! test methods
      use ESMF

      implicit none

!------------------------------------------------------------------------------
! The following line turns the CVS identifier string into a printable variable.
      character(*), parameter :: version = &
      '$Id$'
!------------------------------------------------------------------------------
      ! cumulative result: count failures; no failures equals "all pass"
      integer :: result = 0


      ! individual test failure message
      character(ESMF_MAXSTR) :: failMsg
      character(ESMF_MAXSTR) :: name
      character(len=8) :: strvalue
      character(ESMF_MAXSTR) :: infostring

      ! local variables
      integer:: i, rc
      type(ESMF_VM):: vm
      integer:: localPet, petCount
      integer:: count, src, dst
      integer, allocatable:: localData(:),soln(:)
      real(ESMF_KIND_R8), allocatable:: r8_localData(:),r8_soln(:)
      real(ESMF_KIND_R4), allocatable:: r4_localData(:),r4_soln(:)

      type(ESMF_logical), allocatable:: local_logical(:),logical_soln(:)
     
      integer, allocatable::  i_recvData(:)
      real(ESMF_KIND_R8), allocatable:: r8_recvData(:)
      real(ESMF_KIND_R4), allocatable:: r4_recvData(:)

      type(ESMF_logical), allocatable::  recv_logical(:)
     
      integer :: isum
      real(ESMF_KIND_R8) :: R8Sum
      real(ESMF_KIND_R4) :: R4Sum
      
      type(ESMF_CommHandle):: commhandleI4, commhandleR4, commhandleR8
      type(ESMF_CommHandle):: commhandleLOGICAL

!------------------------------------------------------------------------------
!   The unit tests are divided into Sanity and Exhaustive. The Sanity tests are
!   always run. When the environment variable, EXHAUSTIVE, is set to ON then
!   the EXHAUSTIVE and sanity tests both run. If the EXHAUSTIVE variable is set
!   Special strings (Non-exhaustive and exhaustive) have been
!   added to allow a script to count the number and types of unit tests.
!------------------------------------------------------------------------------


      call ESMF_TestStart(ESMF_SRCLINE, rc=rc)
      if (rc /= ESMF_SUCCESS) call ESMF_Finalize(endflag=ESMF_END_ABORT)

      ! Get count of PETs and which PET number we are
      call ESMF_VMGetGlobal(vm, rc=rc)
      call ESMF_VMGet(vm, localPet=localPet, petCount=petCount, rc=rc)

      ! Allocate localData
      count = 2

!------------------------------------------------------------------------------
! IMPORTANT NOTE:
!   The correct operation of this unit test in uni-process mode depends on 
!   sufficient internal buffering inside ESMF_VMSendRecv! There will be an 
!   implementation specific threshold for count above which this unit test will 
!   start to hang!
!------------------------------------------------------------------------------

      allocate(localData(count))
      allocate(r8_localData(count))
      allocate(r4_localData(count))
      allocate(local_logical(count))

      allocate(i_recvData(count))
      allocate(r8_recvData(count))
      allocate(r4_recvData(count))
      allocate(recv_logical(count))

      ! Allocate the solution arrays
      Allocate(soln(count))
      Allocate(r8_soln(count))
      Allocate(r4_soln(count))
      allocate(logical_soln(count))

      !Assign values
      do i=1,count
        localData(i)    = localPet*100+i 
        r4_localData(i) = real( localData(i) , ESMF_KIND_R4 )
        r8_localData(i) = real( localData(i) , ESMF_KIND_R8)
        if (mod(localData(i)+localPet,2).eq.0) then
          local_logical(i)= ESMF_TRUE
        else
          local_logical(i)= ESMF_FALSE
        endif
      end do 

!===============================================================================
! First round of tests use explicit commhandles and wait on each call 
! individually.
!===============================================================================

      ! Set src and dst for the first round
      src = localPet - 1
      do while (src < 0) 
        src = src + petCount
      enddo
      dst = localPet + 1
      do while (dst > petCount - 1) 
        dst = dst - petCount
      enddo
      
      write(infostring, *) "First round: src=",src," dst=",dst
      call ESMF_LogWrite(infostring, ESMF_LOGMSG_INFO)

      !The solution to test against is..
      do  i=1,count
        soln(i)    = src*100+i
        r8_soln(i) = real( soln(i) , ESMF_KIND_R8)
        r4_soln(i) = real( r8_soln(i))
        if ( mod(soln(i)+src,2) .eq. 0 ) then
          logical_soln(i)= ESMF_TRUE
        else
          logical_soln(i)= ESMF_FALSE
        endif
      end do 

     !Test with integer arguments
     !===========================     
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local I4 data Test"
      call ESMF_VMSendRecv(vm, sendData=localData, sendCount=count, dstPet=dst, &
        recvData=i_recvData, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, commhandle=commhandleI4, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

     !Test with REAL_KIND_R4 arguments
     !================================
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local R4 data Test"
      call ESMF_VMSendRecv(vm, sendData=r4_localData, sendCount=count,  &
        dstPet=dst, recvData=r4_recvData, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, commhandle=commhandleR4, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

     !Test with ESMF_KIND_R8 arguments
     !================================
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local R8 data Test"
      call ESMF_VMSendRecv(vm, sendData=r8_localData, sendCount=count, &
        dstPet=dst, recvData=r8_recvData, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, commhandle=commhandleR8, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

     !Test with logical arguments
     !===========================
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local LOGICAL data Test"
      call ESMF_VMSendRecv(vm, sendData=local_logical, sendCount=count,  &
        dstPet=dst, recvData=recv_logical, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, commhandle=commhandleLOGICAL, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


     !Test with integer arguments
     !===========================     
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Wait on integer sendrecv
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "Waiting for I4 SendRecvNb"
      call ESMF_VMCommWait(vm, commhandleI4, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      isum=0
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local I4 data after receive Test"
      print *,localPet, " After rcv i_recvData is ", i_recvData(1), &
        i_recvData(2),"( should be ",soln(1),soln(2)," )"
      isum=isum+ (i_recvData(1) - soln(1)) + (i_recvData(2) - soln(2))
      call ESMF_Test((isum.eq.0), name, failMsg, result, ESMF_SRCLINE)

     !Test with REAL_KIND_R4 arguments
     !================================
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Wait on R4 sendrecv
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "Waiting for R4 SendRecvNb"
      call ESMF_VMCommWait(vm, commhandleR4, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      R4Sum=0.
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local R4 data after receive Test"
      print *,localPet, "After recv r4_recvData is ", r4_recvData(1), &
        r4_recvData(2),"( should be ", r4_soln(1), r4_soln(2)," )"
      R4Sum=(r4_recvData(1) - r4_soln(1)) +  &
            (r4_recvData(2) - r4_soln(2))
      call ESMF_Test( (R4Sum .eq. 0.0), name, failMsg, result, ESMF_SRCLINE)

     !Test with ESMF_KIND_R8 arguments
     !================================
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Wait on R8 sendrecv
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "Waiting for R8 SendRecvNb"
      call ESMF_VMCommWait(vm, commhandleR8, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      R8Sum=0.
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local R8 data after receive Test"
      print *,localPet, "After recv r8_recvData is ", r8_recvData(1), &
     &       r8_recvData(2),"( Should be ", r8_soln(1), r8_soln(2)," )"
      R8Sum=(r8_recvData(1) - r8_soln(1)) +  &
            (r8_recvData(2) - r8_soln(2))
      call ESMF_Test( (R8Sum .eq. 0.0), name, failMsg, result, ESMF_SRCLINE)

     !Test with logical arguments
     !===========================
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Wait on LOGICAL sendrecv
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "Waiting for LOGICAL SendRecvNb"
      call ESMF_VMCommWait(vm, commhandleLOGICAL, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      ISum=0
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local LOGICAL data after receive Test"

      call ESMF_LogicalString(recv_logical(1), strvalue, rc)
      print *, localPet, "After recv: Recv_Logical(1) is ", trim(strvalue)
      call ESMF_LogicalString(recv_logical(2), strvalue, rc)
      print *, localPet, "After recv: Recv_Logical(2) is ", trim(strvalue)
      call ESMF_LogicalString(logical_soln(1), strvalue, rc)
      print *, localPet, "After recv: Logical_soln(1) is ", trim(strvalue)
      call ESMF_LogicalString(logical_soln(2), strvalue, rc)
      print *, localPet, "After recv: logical_soln(2) is ", trim(strvalue)

      do i=1,count
        if (recv_logical(i).ne. logical_soln(i)) ISum= ISum + 1
      end do
      call ESMF_Test( (ISum .eq. 0), name, failMsg, result, ESMF_SRCLINE)

!===============================================================================
! Second round of tests don't use commhandles but rely on ESMF's internal
! request queue. After all of the non-blocking calls are queued and before
! testing the received values a call to ESMF_VMCommWaitAll() waits on _all_
! outstanding non-blocking communication calls for the current VM.
!===============================================================================

      ! Set src and dst for the second round
      src = localPet - 2
      do while (src < 0) 
        src = src + petCount
      enddo
      dst = localPet + 2
      do while (dst > petCount - 1) 
        dst = dst - petCount
      enddo

      write(infostring, *) "Second round: src=",src," dst=",dst
      call ESMF_LogWrite(infostring, ESMF_LOGMSG_INFO)

      !The solution to test against is..
      do  i=1,count
        soln(i)    = src*100+i
        r8_soln(i) = real( soln(i) , ESMF_KIND_R8)
        r4_soln(i) = real( r8_soln(i))
        if ( mod(soln(i)+src,2) .eq. 0 ) then
          logical_soln(i)= ESMF_TRUE
        else
          logical_soln(i)= ESMF_FALSE
        endif
      end do 

     !Test with integer arguments
     !===========================     
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local I4 data Test"
      call ESMF_VMSendRecv(vm, sendData=localData, sendCount=count, dstPet=dst, &
        recvData=i_recvData, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

     !Test with REAL_KIND_R4 arguments
     !================================
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local R4 data Test"
      call ESMF_VMSendRecv(vm, sendData=r4_localData, sendCount=count,  &
        dstPet=dst, recvData=r4_recvData, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

     !Test with ESMF_KIND_R8 arguments
     !================================
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local R8 data Test"
      call ESMF_VMSendRecv(vm, sendData=r8_localData, sendCount=count, &
        dstPet=dst, recvData=r8_recvData, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)

     !Test with logical arguments
     !===========================
      !NEX_UTest
      ! Send local data to dst
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "SendRecvNb local LOGICAL data Test"
      call ESMF_VMSendRecv(vm, sendData=local_logical, sendCount=count,  &
        dstPet=dst, recvData=recv_logical, recvCount=count, srcPet=src, &
        syncflag=ESMF_SYNC_NONBLOCKING, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


     !Test the VMCommWaitAll function to wait on all outstanding nb comms for VM
     !===========================     
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Wait on integer sendrecv
      write(failMsg, *) "Did not RETURN ESMF_SUCCESS"
      write(name, *) "Waiting for all queued non-blocking comms in VM"
      call ESMF_VMCommWaitAll(vm, rc=rc)
      call ESMF_Test((rc.eq.ESMF_SUCCESS), name, failMsg, result, ESMF_SRCLINE)


     !Test with integer arguments
     !===========================     
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      isum=0
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local I4 data after receive Test"
      print *,localPet, " After rcv i_recvData is ", i_recvData(1), &
    &        i_recvData(2),"( should be ",soln(1),soln(2)," )"
      isum=isum+ (i_recvData(1) - soln(1)) + (i_recvData(2) - soln(2))
      call ESMF_Test((isum.eq.0), name, failMsg, result, ESMF_SRCLINE)

     !Test with REAL_KIND_R4 arguments
     !================================
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      R4Sum=0.
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local R4 data after receive Test"
      print *,localPet, "After recv r4_recvData is ", r4_recvData(1), &
     &        r4_recvData(2),"( should be ", r4_soln(1), r4_soln(2)," )"
      R4Sum=(r4_recvData(1) - r4_soln(1)) +  &
            (r4_recvData(2) - r4_soln(2))
      call ESMF_Test( (R4Sum .eq. 0.0), name, failMsg, result, ESMF_SRCLINE)

     !Test with ESMF_KIND_R8 arguments
     !================================
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      R8Sum=0.
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local R8 data after receive Test"
      print *,localPet, "After recv r8_recvData is ", r8_recvData(1), &
     &       r8_recvData(2),"( Should be ", r8_soln(1), r8_soln(2)," )"
      R8Sum=(r8_recvData(1) - r8_soln(1)) +  &
            (r8_recvData(2) - r8_soln(2))
      call ESMF_Test( (R8Sum .eq. 0.0), name, failMsg, result, ESMF_SRCLINE)

     !Test with logical arguments
     !===========================
      !------------------------------------------------------------------------
      !NEX_UTest
      ! Verify localData after VM Receive
      ISum=0
      write(failMsg, *) "Wrong Local Data"
      write(name, *) "Verify local LOGICAL data after receive Test"

      call ESMF_LogicalString(recv_logical(1), strvalue, rc)
      print *, localPet, "After recv: Recv_Logical(1) is ", trim(strvalue)
      call ESMF_LogicalString(recv_logical(2), strvalue, rc)
      print *, localPet, "After recv: Recv_Logical(2) is ", trim(strvalue)
      call ESMF_LogicalString(logical_soln(1), strvalue, rc)
      print *, localPet, "After recv: Logical_soln(1) is ", trim(strvalue)
      call ESMF_LogicalString(logical_soln(2), strvalue, rc)
      print *, localPet, "After recv: logical_soln(2) is ", trim(strvalue)

      do i=1,count
        if (recv_logical(i).ne. logical_soln(i)) ISum= ISum + 1
      end do
      call ESMF_Test( (ISum .eq. 0), name, failMsg, result, ESMF_SRCLINE)

      deallocate(localData)
      deallocate(r8_localData)
      deallocate(r4_localData)
      deallocate(local_logical)

      deallocate(i_recvData)
      deallocate(r8_recvData)
      deallocate(r4_recvData)
      deallocate(recv_logical)

      deallocate(soln)
      deallocate(r8_soln)
      deallocate(r4_soln)
      deallocate(logical_soln)

      call ESMF_TestEnd(ESMF_SRCLINE)

      end program ESMF_VMSendRecvNbUTest
