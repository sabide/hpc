program pi
  use, intrinsic :: iso_fortran_env, only : dp => real64, li => int64
  use mpi
  implicit none
  integer            :: code,rank, nb_procs
  integer(kind=li)   :: nbblock,i,begin,end
  real(kind=dp)      :: width,sum,global,x
  integer            :: typedp,typeli

  call MPI_INIT(code)
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank,code)
  call MPI_COMM_SIZE(MPI_COMM_WORLD,nb_procs,code)

  ! Interval number
  nbblock = 3*1000*1000_li*100
  ! Interval width
  width = 1._dp / real(nbblock,dp)

  sum = 0._dp

  ! Progressive distribution
  ! rang*nbbloc must be less than 9.10^18
  begin = (rank*nbblock)/nb_procs+1
  end = ((rank+1)*nbblock)/nb_procs

  ! Idem
  ! rang*nbbloc must be less than  9.10^15
  !begin = ((1._dp*rank)*nbblock)/nb_procs+1
  !end = ((1._dp*(rank+1))*nbblock)/nb_procs

  ! Remainder are distributed on the first rank
  !begin = rank*(nbblock/nb_procs)+1+min(rank,mod(nbblock,nb_procs))
  !end = begin+(nbblock/nb_procs)-1
  !if (rank < mod(nbblock,nb_procs)) end = end+1

  ! Remainder are distributed on the last rank
  !begin = rank*(nbblock/nb_procs)+1+max(mod(nbblock,nb_procs)+rank-nb_procs,0)
  !end = begin+(nbblock+rank)/nb_procs-1

  print "(i2,a,i11,a,i11,a,i11)", rank, " begin: ", begin, " end: ", end, " delta: ", end-begin+1

  do i=begin, end
    ! Point in the middle of the interval
    x = width*(i-0.5_dp)
    ! Compute the area
    sum = sum + width*(4._dp / (1._dp + x*x))
  end do
  call MPI_TYPE_CREATE_F90_REAL(precision(sum),range(sum),typedp,code)
  call MPI_REDUCE(sum, global, 1, typedp, MPI_SUM, 0, MPI_COMM_WORLD,code)
  if (rank ==0) print *, "Pi =", global
  if (rank ==0) print *, "Difference =", global-4._dp*atan(1._dp)
  call MPI_TYPE_CREATE_F90_INTEGER(range(begin),typeli,code)
  call MPI_REDUCE(end-begin+1,i, 1, typeli, MPI_SUM, 0, MPI_COMM_WORLD,code)
  !call MPI_REDUCE(end-begin+1,i, 1, MPI_INTEGER8, MPI_SUM, 0, MPI_COMM_WORLD,code)
  if (rank ==0) print *, "Nb =", i

  call MPI_FINALIZE(code)
end program
