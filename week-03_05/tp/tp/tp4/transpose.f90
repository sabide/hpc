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
  INTEGER(kind=MPI_ADDRESS_KIND)           :: sizeDisplacement
  TYPE(MPI_Status)                         :: status

  ! TODO: Get rank -> rank

  !-- AT matrix  initialisation 
  AT(:,:) = 0.

  ! TODO: datatype transpose

  IF (rank == 0) THEN
    !Initialisation of the A matrix on the 0 process
    A(:,:) = RESHAPE( (/ (i,i=1,nb_lines*nb_columns) /), &
                      (/ nb_lines,nb_columns /) )
    PRINT *,'Matrice A'
    DO i=1,nb_lines
      PRINT *,A(i,:)
    END DO
    ! TODO: Send A matrix to process 1
    
  ELSE
    ! TODO: Reception for the process 1 in AT matrix
    
    PRINT *,'Matrix transpose AT'
    DO i=1,nb_lines_t
      PRINT *,AT(i,:)
    END DO
  END IF

  ! TODO: Clean MPI types

  ! TODO : Finalize MPI

END PROGRAM transpose
