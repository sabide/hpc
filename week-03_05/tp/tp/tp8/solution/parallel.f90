MODULE parallel
  USE TYPE_PARAMS
  USE MPI_F08
  IMPLICIT NONE

  !Local Sub-Domain rank
  INTEGER                                   :: rank
  !Number of processes
  INTEGER                                   :: nbrank
  !Communicator of the Cartesian topology
  TYPE(MPI_Comm)                            :: comm2d
  !Number of dimensions for the grid
  INTEGER, PARAMETER                        :: ndims = 2
  !Number of processes in each dimension for the Cartesian topology
  INTEGER, DIMENSION(ndims)                 :: dims
  !Topology periodicity
  LOGICAL, DIMENSION(ndims)                 :: periods
  !Coordinates of the local domain
  INTEGER, DIMENSION(ndims)                 :: coords
  !Array storing the rank of neighbours
  INTEGER, PARAMETER                        :: NB_NEIGHBOURS = 4
  INTEGER, PARAMETER                        :: N=1, E=2, S=3, W=4
  INTEGER, DIMENSION(NB_NEIGHBOURS)         :: neighbour
  !Derived datatypes
  TYPE(MPI_Datatype)                        :: typedp,type_line, type_column
  !MPI
  INTEGER                                   :: code

CONTAINS

  SUBROUTINE env_init
    !************
    !Initialization of the MPI environnement
    !************
    !MPI initialization
    CALL MPI_INIT()
    !Who I am
    CALL MPI_COMM_RANK(MPI_COMM_WORLD, rank)
    !Total number of processes
    CALL MPI_COMM_SIZE(MPI_COMM_WORLD, nbrank)
  END SUBROUTINE env_init

  SUBROUTINE topology_init
    !************
    !Creation of the Cartesian topology
    !************
    !MPI
    LOGICAL, PARAMETER                        :: reorganisation = .FALSE.

    !Read ntx and nty in the file poisson.data
    OPEN(10, FILE='poisson.data', STATUS='OLD')
    READ(10, *) ntx
    READ(10, *) nty
    CLOSE(10)
    !Number of processes on each dimension (depends on the total number of processes)
    dims(:)= 0
    CALL MPI_DIMS_CREATE(nbrank, ndims, dims)

    !Creation of the 2D cartesian topology (no periodicity)
    periods(:) = .FALSE.
    CALL MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dims, periods, &
                         reorganisation, comm2d)
    IF (rank == 0) THEN
      WRITE (*,'(A)') '-----------------------------------------'
      WRITE (*,'(A,i4,A)') 'Execution poisson with ', nbrank, ' MPI processes'
      WRITE (*,'(A,i4,A,i4)') 'Size of the domain: ntx=', ntx, ' nty=', nty
      WRITE (*,'(A,i4,A,i4,A)') 'Dimension for the topology: ', &
            dims(1), ' along x, ', dims(2), ' along  y'
      WRITE (*,'(A)') '-----------------------------------------'
    END IF
  END SUBROUTINE topology_init


  SUBROUTINE domain_boundaries
    !************
    !Computation of the local grid boundary coordinates (global indexes)
    !************
    ! What is my coordinates in the topology
    CALL MPI_CART_COORDS(comm2d, rank, ndims, coords)

    ! X-axis limits
    sx = (coords(1)*ntx)/dims(1)+1
    ex = ((coords(1)+1)*ntx)/dims(1)

    ! Y-axis limits
    sy = (coords(2)*nty)/dims(2)+1
    ey = ((coords(2)+1)*nty)/dims(2)

    WRITE (*,'(A,i4,A,i4,A,i4,A,i4,A,i4,A)') 'Rank in the topology: ', rank, &
             ' Local Grid Index:',  sx, ' to', ex, ' along x, ', &
             sy, ' to', ey, ' along y'
  END SUBROUTINE domain_boundaries

  SUBROUTINE domain_neighbours
    !************
    !Neighbours 
    !************
    !Get the rank of my northern and southern neighbours
    CALL MPI_CART_SHIFT(comm2d, 0, 1, neighbour(N), neighbour(S))

    !Get the rank of my western and eastern neighbours
    CALL MPI_CART_SHIFT(comm2d, 1, 1, neighbour(W), neighbour(E))
    WRITE (*,'(A,i4,A,i4,A,i4,A,i4,A,i4)') "Process ", rank, " neighbour: N", neighbour(N), " E", neighbour(E), &
            " S", neighbour(S), " W", neighbour(W)
  END SUBROUTINE domain_neighbours

  SUBROUTINE derived_datatypes
    !************
    !Creation of the derived datatypes needed to exchange points with neighbours
    !************
    REAL(kind=dp) :: realdp
    CALL MPI_TYPE_CREATE_F90_REAL(precision(realdp),range(realdp),typedp)
    !Creation of the type_line derived datatype to exchange points
    !with northern to southern neighbours
    CALL MPI_TYPE_VECTOR(ey-sy+1, 1, ex-sx+3, &
                         typedp, type_line)
    CALL MPI_TYPE_COMMIT(type_line)
    !Creation of the type_column derived datatype to exchange points
    !with western to eastern neighbours
    CALL MPI_TYPE_CONTIGUOUS(ex - sx + 1, typedp, &
                             type_column)
    CALL MPI_TYPE_COMMIT(type_column)
  END SUBROUTINE derived_datatypes

  SUBROUTINE communications(u)
    !************
    !Exchange the points at the interface
    !************
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(inout) :: u
    !MPI constants
    INTEGER, PARAMETER                   :: tag=100
    TYPE(MPI_Status)                     :: msgstatus

    !Send to neighbour N and receive from neighbour S
    CALL MPI_SENDRECV(u(sx, sy), 1,   type_line,           neighbour(N), &
         tag,  u(ex+1, sy), 1,        type_line,           neighbour(S), &
         tag, comm2d, msgstatus)

    !Send to neighbour S and receive from neighbour N
    CALL MPI_SENDRECV(u(ex, sy), 1,   type_line,           neighbour(S), &
         tag,  u(sx-1, sy), 1,        type_line,           neighbour(N), &
         tag, comm2d, msgstatus)

    !Send to neighbour W  and receive from neighbour E
    CALL MPI_SENDRECV(u(sx, sy), 1, type_column,           neighbour(W), &
         tag,  u(sx, ey+1), 1, type_column,                neighbour(E), &
         tag, comm2d, msgstatus)

    !Send to neighbour E  and receive from neighbour W
    CALL MPI_SENDRECV(u(sx, ey), 1, type_column,           neighbour(E), &
         tag,  u(sx, sy-1), 1, type_column,                neighbour(W), &
         tag, comm2d, msgstatus)

  END SUBROUTINE communications

  FUNCTION global_error(u, u_new)
    !************
    !Compute the global error (maximum of the locals errors)
    !************
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(in) :: u, u_new
    REAL(kind=dp)              :: global_error, local_error
    local_error = MAXVAL (ABS(u(sx:ex, sy:ey) &
                             -u_new(sx:ex, sy:ey)))
    !Computation of global error
    CALL MPI_ALLREDUCE(local_error, global_error, 1, typedp, &
                       MPI_MAX, comm2d)
  END FUNCTION global_error

  SUBROUTINE write_data(u)
    !********************
    ! Write array u inside a domain for each process in the data.dat file
    !********************
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(inout) :: u
    TYPE(MPI_Status)                      :: iostatus
    TYPE(MPI_File)                        :: fh
    INTEGER(kind = MPI_OFFSET_KIND)       :: initial_displacement
    INTEGER, PARAMETER                    :: array_rank=2
    INTEGER, DIMENSION(array_rank)        :: shape_array, shape_sub_array, start_coord
    INTEGER, DIMENSION(array_rank)        :: shape_view_array, shape_sub_view_array, start_view_coord
    TYPE(MPI_Datatype)                    :: type_sub_array, type_sub_view_array

    ! Change error handler for file
    CALL MPI_FILE_SET_ERRHANDLER(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL)

    !Open file "data.dat" in write mode
    CALL MPI_FILE_OPEN(comm2d, "data.dat", &
         MPI_MODE_WRONLY + MPI_MODE_CREATE, &
         MPI_INFO_NULL, fh)
    !Creation of the derived datatype type_sub_view_array for the view on the file
    !Shape of the array
    shape_view_array(:)= (/ ntx, nty /)
    !Shape of the subarray
    shape_sub_view_array(:) = SHAPE(u(sx:ex, sy:ey))
    !Starting coordinates of the subarray
    start_view_coord(:) =  (/ sx-1 , sy-1 /)
    !Creation of the derived datatype type_sub_view_array
    CALL MPI_TYPE_CREATE_SUBARRAY(array_rank, shape_view_array, shape_sub_view_array, &
       start_view_coord, MPI_ORDER_FORTRAN, typedp, type_sub_view_array)
    !Commit type_sub_view_array
    CALL MPI_TYPE_COMMIT(type_sub_view_array)
    !Change the file view
    initial_displacement = 0
    CALL MPI_FILE_SET_VIEW(fh, initial_displacement, typedp, &
         type_sub_view_array, "native", MPI_INFO_NULL)
    !Creation of the derived datatype type_sub_array corresponding to the matrix u without ghost cells
    !Shape  of the array 
    shape_array(:)= SHAPE(u)
    !Shape of the subarray
    shape_sub_array(:) = SHAPE(u(sx:ex, sy:ey))
    !Starting coordinates of the subarray
    start_coord(:) = (/ 1 , 1  /)
    !Creation of the derived datatype type_sub_array
    CALL MPI_TYPE_CREATE_SUBARRAY(array_rank, shape_array, shape_sub_array, start_coord, &
         MPI_ORDER_FORTRAN, typedp, type_sub_array)
    !Commit type_sub_array
    CALL MPI_TYPE_COMMIT(type_sub_array)
    !Write u for each process with the view
    CALL MPI_FILE_WRITE_ALL(fh, u, 1, type_sub_array, iostatus)
    !Close file
    CALL MPI_FILE_CLOSE(fh)
    !Clean MPI type
    CALL MPI_TYPE_FREE(type_sub_array)
    CALL MPI_TYPE_FREE(type_sub_view_array)
  END SUBROUTINE write_data

  SUBROUTINE env_finalize
    !Clean MPI objects
    CALL MPI_TYPE_FREE(type_line)
    CALL MPI_TYPE_FREE(type_column)
    CALL MPI_COMM_FREE(comm2d)
    !Terminates MPI execution environment
    CALL MPI_FINALIZE()
  END SUBROUTINE env_finalize
END MODULE parallel
