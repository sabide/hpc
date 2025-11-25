
program ping_pong_2
  USE MPI_F08
  implicit none

  TYPE(MPI_Status)                     :: status
  integer                              :: nb_values
  integer, parameter                   :: tag=99
  integer                              :: rank
  ! Kind for double precision
  integer, parameter                   :: dp = selected_real_kind(15,307)
  real(kind=dp)                        :: time_begin,time_end
  real(kind=dp), dimension(:) , allocatable  :: values
  TYPE(MPI_Datatype)                   :: typedp
  
  !......................................................................
  
  call MPI_INIT()

  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_TYPE_CREATE_F90_REAL(15,307,typedp)

  if (rank == 0) then
     print*,'enter the size of the array to send-recv'
     read(*,*) nb_values
     CALL MPI_SEND(nb_values,1,MPI_INTEGER,1,TAG, MPI_COMM_WORLD)
  else
     CALL MPI_RECV(nb_values,1,MPI_INTEGER,0,TAG, MPI_COMM_WORLD,STATUS) 
  end if

  allocate(values(nb_values))

  
  if (rank == 0) then
     call random_number(values)
     time_begin=MPI_WTIME()
     !......................................................................

     CALL MPI_SEND(VALUES,NB_VALUES,TYPEDP,1,TAG, MPI_COMM_WORLD)        ! i send to rank 1
     CALL MPI_RECV(VALUES,NB_VALUES,TYPEDP,1,TAG, MPI_COMM_WORLD,STATUS) ! i receive from 1

     time_end=MPI_WTIME()
     print ('("Me, process 0, sent and received ",i10, &
          & " values (last = ",f4.2,") from process 1", &
          & " in ",e15.8," seconds.")'), &
          nb_values,values(nb_values),time_end-time_begin

     print('(" ")')
     print ('("msg ",i10," ",e15.8)'),nb_values,time_end-time_begin
     
     
  elseif (rank == 1) then

     call MPI_RECV(values,nb_values,typedp,0,tag, MPI_COMM_WORLD,status) ! i receive from 0
     call MPI_SEND(values,nb_values,typedp,0,tag, MPI_COMM_WORLD)        ! i send to 0

     
  end if

  
  call mpi_finalize()
end program ping_pong_2
