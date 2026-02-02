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

  ! Get rank -> rank
  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_TYPE_CREATE_F90_REAL(precision(values),range(values),typedp)

  if (rank == 0) then
    call random_number(values)
    ! Start timing -> time_begin
    time_begin=MPI_WTIME()
    ! Process 0 send values to and receive from process 1
    call MPI_SEND(values,nb_values,typedp,1,tag, &
                  MPI_COMM_WORLD)
    call MPI_RECV(values,nb_values,typedp,1,tag, &
                  MPI_COMM_WORLD,status)
    ! End timing -> time_end
    time_end=MPI_WTIME()
    print ('("Me, process 0, sent and received ",i5, &
        & " values (last = ",f4.2,") from process 1", &
        & " in ",f8.6," seconds.")'), &
          nb_values,values(nb_values),time_end-time_begin
  elseif (rank == 1) then
    ! Process 1 receive values from and send to process 0
    call MPI_RECV(values,nb_values,typedp,0,tag, &
                  MPI_COMM_WORLD,status)
    call MPI_SEND(values,nb_values,typedp,0,tag, &
                  MPI_COMM_WORLD)
  end if

! Finalize MPI
  call MPI_FINALIZE()
end program ping_pong_2
