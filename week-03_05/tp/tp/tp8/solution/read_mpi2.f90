PROGRAM read
  use, intrinsic :: iso_fortran_env, only : dp => real64
  USE mpi

  IMPLICIT NONE

  INTEGER, DIMENSION(MPI_STATUS_SIZE)            :: status
  INTEGER                                        :: rank, code, fh, ntx, nty
  REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :)    :: u_read
  INTEGER(KIND=MPI_OFFSET_KIND)                  :: file_size
  INTEGER                                        :: double_size
  INTEGER                                        :: typedp
  character(len=MPI_MAX_ERROR_STRING)            :: text_error
  integer                                        :: text_length
  
  CALL MPI_INIT(code)

  CALL MPI_COMM_RANK(MPI_COMM_WORLD, rank, code)

  OPEN(11, FILE='poisson.data', STATUS='OLD')
  READ(11, *) ntx
  READ(11, *) nty
  CLOSE(11)

  ALLOCATE(u_read(ntx, nty))
  u_read(:, :) = 0.d0

  CALL MPI_FILE_OPEN(MPI_COMM_WORLD, "data.dat", &
   MPI_MODE_RDONLY, MPI_INFO_NULL, fh, code)
  if (code /= MPI_SUCCESS) then
    CALL MPI_ERROR_STRING(code,text_error,text_length)
    print *, text_error(1:text_length)
    call MPI_ABORT(MPI_COMM_WORLD,42)
  end if

  CALL MPI_FILE_SET_ERRHANDLER(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL,code)
  CALL MPI_FILE_GET_SIZE(fh, file_size, code)
  CALL MPI_TYPE_CREATE_F90_REAL(precision(u_read),range(u_read),typedp,code)
  CALL MPI_TYPE_SIZE(typedp, double_size, code)
  if (file_size /= ntx*nty*double_size) then
    print *, " ATTENTION data.dat does not have the good size"
    print *, " Size of the file : ", file_size
    print *, " Size wanted : ", ntx*nty*double_size
    write(11,*) 0
  else
    CALL MPI_FILE_READ(fh, u_read, SIZE(u_read), &
     typedp, status, code)
    WRITE(11, 101)  u_read
101 FORMAT (E19.12)
  end if

  CALL MPI_FILE_CLOSE(fh, code)
  
  CALL MPI_FINALIZE(code)

END PROGRAM read
