program even_odd
  USE MPI_F08
  implicit none

  integer :: rank,nb_procs

  call MPI_INIT()

  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_COMM_SIZE(MPI_COMM_WORLD,nb_procs)

  if (mod(rank,2) == 0) then
    print *,'I am the even-ranked process my rank is ',rank
  else
    print *,'I am the odd-ranked process my rank is ',rank
  end if

  call MPI_FINALIZE()

end program even_odd
