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
    ! TODO: Get rank and number of processes -> rank, nbrank
    
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
    ! TODO: Number of processes on each dimension -> dims
    
    ! TODO: Creation of the 2D cartesian topology (no periodicity) -> comm2d
   
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
    ! TODO:What is my coordinates in the topology -> coords
    

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
    ! TODO: Get the rank of my northern and southern neighbours -> neighbour(N), neighbour(S)
    
    ! TODO: Get the rank of my western and eastern neighbours -> neighbour(W), neighbour(E)
    
    WRITE (*,'(A,i4,A,i4,A,i4,A,i4,A,i4)') "Process ", rank, " neighbour: N", neighbour(N), " E", neighbour(E), &
            " S", neighbour(S), " W", neighbour(W)
  END SUBROUTINE domain_neighbours

  SUBROUTINE derived_datatypes
    !************
    !Creation of the derived datatypes needed to exchange points with neighbours
    !************
    REAL(kind=dp) :: realdp
    ! TODO: Creation of the type_line derived datatype to exchange points
    !with northern to southern neighbours
    
    ! TODO: Creation of the type_column derived datatype to exchange points
    !with western to eastern neighbours
   
  END SUBROUTINE derived_datatypes

  SUBROUTINE communications(u)
    !************
    !Exchange the points at the interface
    !************
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(inout) :: u
    !MPI constants
    INTEGER, PARAMETER                   :: tag=100
    TYPE(MPI_Status)                     :: msgstatus

    ! TODO: Send to neighbour N and receive from neighbour S
    
    ! TODO: Send to neighbour S and receive from neighbour N
    
    ! TODO: Send to neighbour W  and receive from neighbour E
   
    ! TODO: Send to neighbour E  and receive from neighbour W
    
  END SUBROUTINE communications

  FUNCTION global_error(u, u_new)
    !************
    !Compute the global error (maximum of the locals errors)
    !************
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(in) :: u, u_new
    REAL(kind=dp)              :: global_error, local_error
    local_error = MAXVAL (ABS(u(sx:ex, sy:ey) &
                             -u_new(sx:ex, sy:ey)))
    ! TODO: Computation of global error
    
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

    ! TODO: Change error handler for file

    ! TODO: Open file "data.dat" in write mode

    ! TODO: Creation of the derived datatype type_sub_view_array for the view on the file

    ! TODO: Change the file view

    ! TODO: Creation of the derived datatype type_sub_array corresponding to the matrix u without ghost cells

    ! TODO: Write u for each process with the view

    ! TODO: Close file

    ! TODO: Clean MPI type

  END SUBROUTINE write_data

  SUBROUTINE env_finalize
    ! TODO: Clean MPI objects

    ! TODO: Terminates MPI execution environment

  END SUBROUTINE env_finalize
END MODULE parallel
