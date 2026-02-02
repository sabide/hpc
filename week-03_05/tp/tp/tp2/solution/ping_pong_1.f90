program ping_pong_1
  use, intrinsic :: iso_fortran_env, only : dp => real64
  USE MPI_F08
  implicit none

  TYPE(MPI_Status)                     :: status
  integer, parameter                   :: nb_values=1000,tag=99
  integer                              :: rank
  real(kind=dp), dimension(nb_values)  :: values
  TYPE(MPI_Datatype)                   :: typedp

  ! Initialize MPI
  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_TYPE_CREATE_F90_REAL(precision(values),range(values),typedp)

  if (rank == 0) then
    call random_number(values)
    call MPI_SEND(values,nb_values,typedp,1,tag, &
                  MPI_COMM_WORLD)
  elseif (rank == 1) then
    call MPI_RECV(values,nb_values,typedp,0,tag, &
                  MPI_COMM_WORLD,status)
    print ('("Me, process 1, received ",i4," values (last = ", &
           & f4.2,") from process 0.")'), nb_values,values(nb_values)
  end if

  call MPI_FINALIZE()

end program ping_pong_1
