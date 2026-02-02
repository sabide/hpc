program ping_pong_1
  use, intrinsic :: iso_fortran_env, only : dp => real64
  USE MPI
  implicit none

  integer, dimension(MPI_STATUS_SIZE) :: status
  integer, parameter                  :: nb_values=1000,tag=99
  integer                             :: rank,code
  real(kind=dp), dimension(nb_values)  :: values
  integer                              :: typedp

  call MPI_INIT(code)

  call MPI_COMM_RANK(MPI_COMM_WORLD,rank,code)
  call MPI_TYPE_CREATE_F90_REAL(precision(values),range(values),typedep,code)

  if (rank == 0) then
    call random_number(values)
    call MPI_SEND(values,nb_values,typedp,1,tag, &
                  MPI_COMM_WORLD,code)
  elseif (rank == 1) then
    call MPI_RECV(values,nb_values,typedp,0,tag, &
                  MPI_COMM_WORLD,status,code)
    print ('("Me, process 1, received ",i4," values (last = ", &
           & f4.2,") from process 0.")'), nb_values,values(nb_values)
  end if

  call MPI_FINALIZE(code)

end program ping_pong_1
