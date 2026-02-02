PROGRAM transpose
  USE MPI_F08
  IMPLICIT NONE
  INTEGER, PARAMETER                       :: nb_lines=5,nb_columns=4,&
                                              nb_lines_t=4,nb_columns_t=5,&
                                              tag=1000
  INTEGER                                  :: rank,size_real,i
  TYPE(MPI_Datatype)                       :: type_line,type_transpose
  REAL, DIMENSION(nb_lines,nb_columns)     :: A
  REAL, DIMENSION(nb_lines_t,nb_columns_t) :: AT
  INTEGER(kind=MPI_ADDRESS_KIND)           :: new_size, new_lb=0
  TYPE(MPI_Status)                         :: status

  !-- MPI init 
  CALL MPI_INIT()

  !-- Who I am
  CALL MPI_COMM_RANK(MPI_COMM_WORLD,rank)

  !-- AT matrix  initialisation 
  AT(:,:) = 0.

  !Size of the generic datatype MPI_REAL
  CALL MPI_TYPE_SIZE(MPI_REAL,size_real)

  !Creation of the derived datatype type_line 
  !for one line of the A matrix
  CALL MPI_TYPE_VECTOR(nb_columns,1,nb_lines,MPI_REAL,type_line)

  !Creation of the derived datatype type_transpose to transpose the
  !A matrix nb_lines lines and nb_columns columns
  new_size=size_real
  CALL MPI_TYPE_CREATE_RESIZED(type_line,new_lb,new_size,&
                               type_transpose)

  !Validation of the derived datatype type_transpose
  CALL MPI_TYPE_COMMIT(type_transpose)

  IF (rank == 0) THEN
    !Initialisation of the A matrix on the 0 process
    A(:,:) = RESHAPE( (/ (i,i=1,nb_lines*nb_columns) /), &
                      (/ nb_lines,nb_columns /) )
    PRINT *,'Matrice A'
    DO i=1,nb_lines
      PRINT *,A(i,:)
    END DO
    !Send A matrix to process 1 using the derived datatype type_transpose
    CALL MPI_SEND(A,nb_lines,type_transpose,1,tag,MPI_COMM_WORLD)
  ELSE
    !Reception for the process 1 in AT matrix
    CALL MPI_RECV(AT,nb_lines_t*nb_columns_t,MPI_REAL,0,tag,&
                  MPI_COMM_WORLD,status)
    PRINT *,'Matrix transpose AT'
    DO i=1,nb_lines_t
      PRINT *,AT(i,:)
    END DO
  END IF

  ! Clean MPI types
  CALL MPI_TYPE_FREE(type_transpose)
  CALL MPI_TYPE_FREE(type_line)
  !MPI finalize
  CALL MPI_FINALIZE()
END PROGRAM transpose
