program ping_pong_1  
USE MPI_F08
  implicit none

  TYPE(MPI_Status)                     :: status
  integer, parameter                   :: nb_values=1000,tag=99
  integer                              :: rank
  ! Kind for double precision
  integer, parameter                   :: dp = selected_real_kind(15,307)
  real(kind=dp), dimension(nb_values)  :: values
  TYPE(MPI_Datatype)                   :: typedp

!......................................................................

    call random_number(values)

!......................................................................

    print ('("Me, process 1, received ",i4," values (last = ", &
           & f4.2,") from process 0.")'), nb_values,values(nb_values)
!......................................................................
 

end program ping_pong_1
