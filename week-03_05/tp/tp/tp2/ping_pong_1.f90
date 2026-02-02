program ping_pong_1
  use, intrinsic :: iso_fortran_env, only : dp => real64
  USE MPI_F08
  implicit none

  TYPE(MPI_Status)                     :: status
  integer, parameter                   :: nb_values=1000,tag=99
  integer                              :: rank
  real(kind=dp), dimension(nb_values)  :: values
  TYPE(MPI_Datatype)                   :: typedp

  !.TODO: Initialize MPI

    call random_number(values)
    ! TODO: Process 0 send values to process 1

    ! TODO: Process 1 receive values from process 0

    print ('("Me, process 1, received ",i4," values (last = ", &
           & f4.2,") from process 0.")'), nb_values,values(nb_values)

  ! TODO: Finalize MPI

end program ping_pong_1
