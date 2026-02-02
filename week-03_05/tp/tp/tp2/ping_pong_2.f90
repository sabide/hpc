program ping_pong_2
  use, intrinsic :: iso_fortran_env, only : dp => real64
  USE MPI_F08
  implicit none

  TYPE(MPI_Status)                     :: status
  integer, parameter                   :: nb_values=1000,tag=99
  integer                              :: rank
  real(kind=dp)                        :: time_begin,time_end
  real(kind=dp), dimension(nb_values)  :: values
  TYPE(MPI_Datatype)                   :: typedp

  ! TODO Get rank -> rank

  if (rank == 0) then
    call random_number(values)
    ! TODO: Start timing -> time_begin

    ! TODO: Process 0 send values to and receive from process 1

    ! TODO: End timing -> time_end

    print ('("Me, process 0, sent and received ",i5, &
        & " values (last = ",f4.2,") from process 1", &
        & " in ",f8.6," seconds.")'), &
          nb_values,values(nb_values),time_end-time_begin

    ! TODO: Process 1 receive values from and send to process 0

  end if

! TODO: Finalize MPI

end program ping_pong_2
