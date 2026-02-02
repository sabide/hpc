program matrix_products
  use mpi
  implicit none
  integer, parameter                  :: tag=1000
  integer                             :: rank, Nprocs, N, NL, code, k, type_temp, type_slice
  integer                             :: rank_next, rank_previous, size_real_type
  integer, dimension(MPI_STATUS_SIZE) :: statut
  real                                :: Emax
  real, allocatable, dimension(:,:)   :: A, B, C, CC, E
  real, allocatable, dimension(:,:)   :: AL, BL, CL, TEMP
  integer(kind=MPI_ADDRESS_KIND)      :: lower_bound=0, size_type_slice
  character(len=256)                  :: arg

  ! MPI initialisation
  call MPI_INIT(code)
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank, code)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, Nprocs, code)

  if (rank == 0) then
    if (command_argument_count() < 1) then
      N=4
    else
      call get_command_argument(1,arg)
      read(arg, '(i6)') N
    end if
  end if

  ! The process 0 bcasts N to other processes
  call MPI_BCAST(N, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, code)

  ! N must be divide by Nprocs
  if ( mod(N, Nprocs) == 0 ) then
    if (rank == 0) print *, "Matrix Size: ", N
    NL = N / Nprocs
  else
    print *, 'N=',N, ' not divide by Nprocs=', Nprocs
    ! Stop the run
    call MPI_ABORT(MPI_COMM_WORLD, 1, code)
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

  call MPI_TYPE_SIZE(MPI_REAL, size_real_type, code)

  ! Creation of the derived datatype for 1 block with NL lines and N columns
  call MPI_TYPE_VECTOR(N, NL, N, MPI_REAL, type_temp, code)
  size_type_slice = size_real_type*NL
  call MPI_TYPE_CREATE_RESIZED(type_temp, lower_bound, size_type_slice, &
                               type_slice, code)
  call MPI_TYPE_COMMIT(type_slice, code)

  ! The process 0 distribute in AL the horizontal slices of A
  call MPI_SCATTER(A, 1, type_slice, AL, N*NL, MPI_REAL, 0, MPI_COMM_WORLD, code)

  ! The process 0 distribute in BL the vertical slices of B
  call MPI_SCATTER(B, N*NL, MPI_REAL, BL, N*NL, MPI_REAL, 0, MPI_COMM_WORLD, code)

  ! Calculation for the diagonal blocks
  CL(rank*NL+1:(rank+1)*NL,:) = matmul( AL(:,:), BL(:,:) )

  ! Calculation for the none-diagonal blocks
!  ! First algorithm (twice as expensive as the second one)
!  do k = 0, Nprocs-1
!    if (rank /= k) then
!      ! Each process sends his Al slice to process k
!      ! and receives in TEMP the AL slice of process k
!      call MPI_SENDRECV(AL,   NL*N, MPI_REAL, k, tag, &
!                         TEMP, NL*N, MPI_REAL, k, tag, MPI_COMM_WORLD, statut, code)
!
!      ! Each process calculates his block above and below the diagonal block
!      CL(k*NL+1:(k+1)*NL,:)=matmul(TEMP(:,:),BL(:,:))
!    end if
!  end do
  ! Second algorithm
  rank_previous = mod(Nprocs+rank-1,Nprocs)
  rank_next   = mod(rank+1,Nprocs)
  do k = 1, Nprocs-1
    ! Each process sends his AL slice to his previous process
    ! and receives the AL slice from the next process (the values of AL changed)
    call MPI_SENDRECV_REPLACE(AL, NL*N, MPI_REAL, rank_previous, tag, &
                              rank_next, tag, MPI_COMM_WORLD, statut, code)
    ! Each process calculates his block above and below the diagonal block
    CL(mod(rank+k,Nprocs)*NL+1:(mod(rank+k,Nprocs)+1)*NL,:)=matmul(AL(:,:),BL(:,:))
  end do

  ! The process 0 gathers all the CL slices from each processes to form the C matrix
  call MPI_GATHER(CL, NL*N, MPI_REAL, C, NL*N, MPI_REAL, 0, MPI_COMM_WORLD, code)

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

  call MPI_TYPE_FREE(type_slice,code)
  call MPI_TYPE_FREE(type_temp,code)
  call MPI_FINALIZE(code)
end program matrix_products
