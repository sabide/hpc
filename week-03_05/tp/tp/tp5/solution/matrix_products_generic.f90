program matrix_products
  use mpi_f08
  implicit none
  integer, parameter                  :: tag=1000
  integer                             :: rank, Nprocs, N, NL, k
  integer                             :: rank_next, rank_previous, size_real_type
  TYPE(MPI_Status)                    :: statut
  real                                :: Emax
  real, allocatable, dimension(:,:)   :: A, B, C, CC, E
  real, allocatable, dimension(:,:)   :: AL, BL, CL, TEMP
  integer                             :: NLmax, remainder
  TYPE(MPI_Datatype)                  :: type_slice1, type_slice2
  integer                             :: krank
  integer, allocatable, dimension(:)  :: Ndist
  integer, allocatable, dimension(:)  :: nbrS, dispS
  TYPE(MPI_Datatype), allocatable, dimension(:) :: typeS, typeR
  integer, allocatable, dimension(:)  :: nbrR, dispR
  integer, allocatable, dimension(:)  :: position
  character(len=256)                  :: arg

  ! MPI initialisation
  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, Nprocs)

  if (rank == 0) then
    if (command_argument_count() < 1) then
      N=4
    else
      call get_command_argument(1,arg)
      read(arg, '(i6)') N
    end if
  end if

  ! The process 0 bcasts N to other processes
  call MPI_BCAST(N, 1, MPI_INTEGER, 0, MPI_COMM_WORLD)

  if (rank == 0) print *, "Matrix Size: ", N
  NL = N / Nprocs
  NLmax = NL
  remainder = mod(N,Nprocs)
  NLmax=NLmax+1
  if (rank < remainder) NL=NL+1
  allocate(Ndist(0:Nprocs-1))
  call MPI_ALLGATHER(NL,1,MPI_INTEGER,Ndist,1,MPI_INTEGER,MPI_COMM_WORLD)

  ! The process 0 initializes the matrices A and B 
  if (rank == 0) then
    ! Dynamic allocation for matrices A, B , C
    allocate( A(N,N), B(N,N), C(N,N), CC(N,N) )
    ! Initialization of A and B
    call RANDOM_NUMBER(A)
    call RANDOM_NUMBER(B)
    ! Mono-processor calculation for the matrix product A*B
    CC(:,:) = matmul(A(:,:), B(:,:))
  else
    ! Avoid trouble with -check all
    allocate( A(0,0), B(0,0), C(0,0))
  end if

  ! Dynamic allocation for locals arrays
  allocate( AL(NL,N), BL(N,NL), CL(N,NL), TEMP(NLmax,N) )

  ! The process 0 distribute in AL the horizontal slices of A
  allocate(nbrS(Nprocs))
  allocate(dispS(Nprocs))
  allocate(typeS(Nprocs))
  if (rank == 0) then
    nbrS(:) = 1
  else
    nbrS(:) = 0
  end if
  dispS(1) = 0
  call MPI_TYPE_SIZE(MPI_REAL, size_real_type)
  do k=2, Nprocs
    dispS(k) = dispS(k-1)+Ndist(k-2)*size_real_type
  end do
  
  call MPI_TYPE_VECTOR(N, NLmax, N, MPI_REAL, type_slice1)
  call MPI_TYPE_COMMIT(type_slice1)
  call MPI_TYPE_VECTOR(N, NLmax-1, N, MPI_REAL, type_slice2)
  call MPI_TYPE_COMMIT(type_slice2)
  do k=1, Nprocs
    if (k-1 < remainder) then
      typeS(k) = type_slice1
    else
      typeS(k) = type_slice2
    end if
  end do
  allocate(nbrR(Nprocs))
  allocate(dispR(Nprocs))
  allocate(typeR(Nprocs))
  nbrR(:) = 0
  nbrR(1) = N*NL
  dispR(:) = 0
  typeR(:) = MPI_REAL
  call MPI_ALLTOALLW(A, nbrS, dispS, typeS, AL, nbrR, dispR, typeR, MPI_COMM_WORLD)

  ! The process 0 distribute in BL the vertical slices of B
  nbrS(:) = 0
  dispS(:) = 0
  do k=1, Nprocs
    nbrS(k) = N*Ndist(k-1)
  end do
  do k=2, Nprocs
    dispS(k) = dispS(k-1)+nbrS(k-1)
  end do
  call MPI_SCATTERV(B, nbrS, dispS, MPI_REAL, BL, N*NL, MPI_REAL, 0, MPI_COMM_WORLD)

  ! Position in C
  allocate(position(0:Nprocs))
  position(0) = 1
  do k=1, Nprocs
    position(k) = position(k-1)+Ndist(k-1)
  end do

  ! Calculation for the diagonal blocks
  CL(position(rank):position(rank+1)-1,:) = matmul( AL(:,:), BL(:,:) )

  ! Calculation for the none-diagonal blocks

!  ! First algorithm (twice as expensive as the second one)
!  do k = 0, Nprocs-1
!    if (rank /= k) then
!      ! Each process sends his AL slice to process k
!      ! and receives in TEMP the AL slice of process k
!      call MPI_SENDRECV(AL,   NL*N, MPI_REAL, k, tag, &
!                        TEMP, NL*N, MPI_REAL, k, tag, MPI_COMM_WORLD, statut)
!      ! Each process calculates his block above and below the diagonal block
!      CL(k*NL+1:(k+1)*NL,:)=matmul(TEMP(:,:),BL(:,:))
!    end if
!  end do
  ! Second algorithm
  rank_previous = mod(Nprocs+rank-1,Nprocs)
  rank_next   = mod(rank+1,Nprocs)
  TEMP(:,:) = 0
  TEMP(:NL,:) = AL(:,:)
  do k = 1, Nprocs-1
    ! Each process sends his AL slice to his previous process
    ! and receives the AL slice from the next process (the values of AL changed)
    call MPI_SENDRECV_REPLACE (TEMP, NLmax*N, MPI_REAL, &
                               rank_previous, tag, &
                               rank_next, tag, &
                               MPI_COMM_WORLD, statut)
    ! Each processus calculates his block above and below the diagonal block
    krank = mod(rank+k,Nprocs)
    CL(position(krank):position(krank+1)-1,:)=matmul(TEMP(:Ndist(krank),:),BL(:,:))
  end do

  ! The process 0 gathers all the CL slices from each processes to form the C matrix
  call MPI_GATHERV(CL, NL*N, MPI_REAL, C, nbrS, dispS, MPI_REAL, 0, MPI_COMM_WORLD)

  ! Deallocate locals arrays
  deallocate( AL, BL, CL, TEMP )
  ! Verification of the results
  if (rank == 0) then
    allocate( E(N,N) )
    E(:,:) = abs(C(:,:) - CC(:,:))
    Emax   = maxval( E(:,:) ) / N**2
    deallocate( A, B, C, CC, E )
    if ( Emax <= epsilon(1.0) ) then
      print'(/,40X,"Super !",/,  &
            & 20X,"Matrix product A*B in parallel",/, &
            & 20X,"equal the mono-processor one")'
    else
      print'(/,33X,"False result !",/, &
            & 20X,"Matrix product A*B in parallel",/, &
            & 20X,"different from the mono-processor one")'
    end if
  end if

  call MPI_TYPE_FREE(type_slice1)
  call MPI_TYPE_FREE(type_slice2)
  call MPI_FINALIZE()
end program matrix_products
