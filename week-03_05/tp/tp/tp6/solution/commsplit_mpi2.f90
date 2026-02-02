!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! commsplit.f90 --- Subdividing a 2D cartesian topology
!!                   with MPI_COMM_SPLIT
!!
!! 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program commsplit
  use MPI

  implicit none

  integer                        :: CommCart2D,CommCart1D
  integer, parameter             :: NDimCart2D=2
  integer, dimension(NDimCart2D) :: DimCart2D,CoordCart2D
  logical, dimension(NDimCart2D) :: Periods
  logical                        :: Reorder
  integer                        :: nb_procs,rank,i,code
  integer, parameter             :: m=4
  real, dimension(m)             :: V
  real                           :: W

  call MPI_INIT( code )
  call MPI_COMM_SIZE( MPI_COMM_WORLD, nb_procs, code )

  !*** 2D Cartesian topology
  DimCart2D(1) = 4
  DimCart2D(2) = 2
  if (DimCart2D(1)*DimCart2D(2) /= nb_procs) then
    print *, "The number of processes is not correct !"
    call MPI_ABORT(MPI_COMM_WORLD,1,code)
  end if

  Periods(:)   = .false.
  Reorder      = .false.

  !*** Creation of the CommCart2D communicator (2D cartesian topology)
  call MPI_CART_CREATE(MPI_COMM_WORLD, NDimCart2D, DimCart2D, &
                       Periods, Reorder, CommCart2D, code)

  call MPI_COMM_RANK(CommCart2D, rank, code)
  call MPI_CART_COORDS(CommCart2D, rank, NDimCart2D, CoordCart2D, code)

  !*** Initialization of the V array and the W scalar
  V(:) = 0.
  W = 0.
  if (CoordCart2D(1) == 1) V(:) = (/ (real(i), i=1,m) /)

  !*** Subdividing the 2D cartesian topology with MPI_COMM_SPLIT
  call MPI_COMM_SPLIT( CommCart2D, CoordCart2D(2), rank, CommCart1D, code)

  !*** The processes of the second row column scatters the V array
  !*** to each process of their line
  call MPI_SCATTER(V,1,MPI_REAL,W,1,MPI_REAL,1,CommCart1D,code)

  print '("Rank : ",I2," ; Coordinates : (",I1,",",I1,") ; W = ",F2.0)', &
        rank,CoordCart2D(1),CoordCart2D(2),W

  !*** Destruction of the communicators
  call MPI_COMM_FREE(CommCart1D,code)
  call MPI_COMM_FREE(CommCart2D,code)

  call MPI_FINALIZE(code)

end program commsplit
