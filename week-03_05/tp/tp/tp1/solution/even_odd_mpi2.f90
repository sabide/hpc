program even_odd
  USE MPI
  implicit none

  integer :: rank,nb_procs,code

  call MPI_INIT(code)

  call MPI_COMM_RANK(MPI_COMM_WORLD,rank,code)
  call MPI_COMM_SIZE(MPI_COMM_WORLD,nb_procs,code)

  if (mod(rank,2) == 0) then
    print *,'I am the even-ranked process my rank is ',rank
  else
    print *,'I am the odd-ranked process my rank is ',rank
  end if

  call MPI_FINALIZE(code)

end program even_odd
