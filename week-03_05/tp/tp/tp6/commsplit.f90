program commsplit
  use MPI_F08
  implicit none
  TYPE(MPI_Comm)                 :: CommCart2D,CommCart1D
  integer, parameter             :: NDimCart2D=2
  integer, dimension(NDimCart2D) :: DimCart2D,CoordCart2D
  logical, dimension(NDimCart2D) :: Periods
  logical                        :: Reorder
  integer                        :: nb_procs,rank,i
  integer, parameter             :: m=4
  real, dimension(m)             :: V
  real                           :: W

  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank)
  call MPI_COMM_SIZE( MPI_COMM_WORLD, nb_procs)

  !*** 2D Cartesian topology
  DimCart2D(1) = 4
  DimCart2D(2) = 2
  if (DimCart2D(1)*DimCart2D(2) /= nb_procs) then
    print *, "The number of processes is not correct !"
    ! TODO: On arrete le programme

  end if

  Periods(:)   = .false.
  Reorder      = .false.

  ! TODO: Creation of the CommCart2D communicator (2D cartesian topology)

  ! TODO: Get coordinates in topology -> CoordCart2D

  !*** Initialization of the V array and the W scalar
  V(:) = 0.
  W = 0.
  if (CoordCart2D(1) == 1) V(:) = (/ (real(i), i=1,m) /)

  ! TODO: Subdividing the 2D cartesian topology with MPI_COMM_SPLIT
  

  ! TODO: The processes of the second column scatter the V array
  ! to processes of their line
  

  print '("Rank : ",I2," ; Coordinates : (",I1,",",I1,") ; W = ",F2.0)', &
        rank,CoordCart2D(1),CoordCart2D(2),W

  ! TODO: Destruction of the communicators
  
  call MPI_FINALIZE()
end program commsplit
