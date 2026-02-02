program matrix_products
  use mpi_f08
  implicit none
  integer, parameter                  :: tag=1000
  integer                             :: rank, Nprocs, N, NL, k
  TYPE(MPI_Datatype)                  :: type_temp, type_slice
  integer                             :: rank_next, rank_previous, size_real_type
  TYPE(MPI_Status)                    :: status
  real                                :: Emax
  real, allocatable, dimension(:,:)   :: A, B, C, CC, E
  real, allocatable, dimension(:,:)   :: AL, BL, CL, TEMP
  integer(kind=MPI_ADDRESS_KIND)      :: lower_bound=0, size_type_slice
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

  ! TODO: The process 0 bcasts N to other processes

  ! N must be divide by Nprocs
  if ( mod(N, Nprocs) == 0 ) then
    if (rank == 0) print *, "Matrix Size: ", N
    NL = N / Nprocs
  else
    print *, 'N=',N, ' not divide by Nprocs=', Nprocs
    ! TODO: Stop the run

  end if

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
  allocate( AL(NL,N), BL(N,NL), CL(N,NL), TEMP(NL,N) )

  ! TODO: Creation of the derived datatype for 1 block with NL lines and N columns

  ! TODO: The process 0 distribute in AL the horizontal slices of A
  
  ! TODO: The process 0 distribute in BL the vertical slices of B
  
  ! Calculation for the diagonal blocks
  CL(rank*NL+1:(rank+1)*NL,:) = matmul( AL(:,:), BL(:,:) )

  ! Calculation for the none-diagonal blocks
  ! First algorithm (speed two twice as expensive than the second one)
  do k = 0, Nprocs-1
    if (rank /= k) then
      ! TODO: Each process sends his Al slice to process k
      ! and receives in TEMP the AL slice of process k

      ! Each process calculates his block above and below the diagonal block
      CL(k*NL+1:(k+1)*NL,:)=matmul(TEMP(:,:),BL(:,:))
    end if
  end do
  ! Second algorithm
  !rank_previous = mod(Nprocs+rank-1,Nprocs)
  !rank_next   = mod(rank+1,Nprocs)
  !do k = 1, Nprocs-1
     ! TODO: Each process sends his AL slice to his previous process 
     ! and receives the AL slice from the next process (the values of AL changed)
     
     ! Each process calculates his block above and below the diagonal block
     !CL(mod(rank+k,Nprocs)*NL+1:(mod(rank+k,Nprocs)+1)*NL,:)=matmul(AL(:,:),BL(:,:))
  !end do

  ! TODO: The process 0 gathers all the CL slices from each processes to form the C matrix
  

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

  call MPI_FINALIZE()
end program matrix_products
