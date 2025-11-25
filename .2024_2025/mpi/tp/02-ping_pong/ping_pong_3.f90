
program ping_pong_3
  USE MPI_F08
  implicit none

  TYPE(MPI_Status)                          :: status
  integer, parameter                        :: nb_tests=24,tag=99
  integer, dimension(nb_tests)              :: nb_values_to_test
  integer                                   :: rank,i,nb_values
  ! Kind for double precision
  integer, parameter                        :: dp = selected_real_kind(15,307)
  real(kind=dp), dimension(:),allocatable   :: values
  TYPE(MPI_Datatype)                        :: typedp
  real(kind=dp)                             :: time_begin,time_end

  call MPI_INIT()


  ! define the size of the data to plot 2^i
  do i=1,nb_tests
     nb_values_to_test(i) = 2**(i) 
  end do
  
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_TYPE_CREATE_F90_REAL(15,307,typedp)

  
  do i=1,nb_tests

     ! get the nb of values  to test and allocate
     nb_values = nb_values_to_test(i)
     allocate( values( nb_values )  )

     ! ping-pong
     if (rank == 0) then
        call random_number(values)
        time_begin = MPI_WTIME()
        call MPI_SEND(values,nb_values,typedp,1,tag, MPI_COMM_WORLD )
        call MPI_RECV(values,nb_values,typedp,1,tag, MPI_COMM_WORLD, status )
        time_end = MPI_WTIME()
        call print_function
     elseif (rank == 1) then
        call MPI_RECV(values,nb_values,typedp,0,tag, MPI_COMM_WORLD,status)
        call MPI_SEND(values,nb_values,typedp,0,tag,MPI_COMM_WORLD)
     end if
     
     deallocate(values)
  end do
  
  call MPI_FINALIZE()
  
contains

  subroutine print_function

    if (nb_values/=0) then
      print ('("Me, process 0, sent and received ",i8, &
           & " values (last = ",f4.2,") from process 1", &
           & " in  ",f8.6," seconds, bandwidth ",f7.2, &
           & " Mo/s.")'), &
           nb_values,values(nb_values-1),time_end-time_begin, &
           real(2*nb_values*8)/1000000./(time_end-time_begin)
    else
      print ('("Me, process 0, sent and received ",i8, &
           & " values in ",f8.6," seconds, bandwidth ",f7.2, &
           & " Mo/s.")'), &
           nb_values,time_end-time_begin, &
           real(2*nb_values*8)/1000000./(time_end-time_begin)
   end if

   print ('("msg ",e15.8," ",e15.8, " " , e15.8 )'),real(nb_values),time_end-time_begin, real(2*nb_values*8)/1000000./(time_end-time_begin)
  end subroutine print_function

end program ping_pong_3
