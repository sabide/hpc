program ping_pong_3
  use, intrinsic :: iso_fortran_env, only : dp => real64
  USE MPI_F08
  implicit none

  TYPE(MPI_Status)                             :: status
  integer, parameter                           :: nb_values_max=7000000, &
                                                  nb_tests=10,tag=99
  integer, dimension(nb_tests)                 :: nb_values
  integer                                      :: rank,i
  real(kind=dp), dimension(0:nb_values_max-1)  :: values
  TYPE(MPI_Datatype)                           :: typedp
  real(kind=dp)                                :: time_begin,time_end

  ! TODO: Get rank -> rank

  nb_values = (/ 0,0,1,10,100,1000,10000,100000,1000000,7000000 /)

  do i=1,nb_tests
    if (rank == 0) then
      call random_number(values)
      ! TODO: Start timing -> time_begin

      ! TODO: Process 0 send values to and receive from process 1

      ! TODO: End timing -> time_end

      call print_function
    elseif (rank == 1) then
      ! TODO: Process 1 receive values from and send to process 0

    end if
  end do

  ! TODO: Finalize MPI
  
contains
  subroutine print_function
    if (nb_values(i)/=0) then
      print ('("Me, process 0, sent and received ",i8, &
           & " values (last = ",f4.2,") from process 1", &
           & " in  ",f8.6," seconds, bandwidth ",f7.2, &
           & " Mo/s.")'), &
           nb_values(i),values(nb_values(i)-1),time_end-time_begin, &
           real(2*nb_values(i)*8)/1000000./(time_end-time_begin)
    else
      print ('("Me, process 0, sent and received ",i8, &
           & " values in ",f8.6," seconds, bandwidth ",f7.2, &
           & " Mo/s.")'), &
           nb_values(i),time_end-time_begin, &
           real(2*nb_values(i)*8)/1000000./(time_end-time_begin)
    end if
  end subroutine print_function
end program ping_pong_3
