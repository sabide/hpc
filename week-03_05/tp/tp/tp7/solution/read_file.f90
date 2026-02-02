program read_file
  use MPI_F08
  implicit none
  integer, parameter                  :: nb_values=121
  integer(kind=MPI_OFFSET_KIND)       :: offset
  integer, dimension(nb_values)       :: values
  TYPE(MPI_Status)                    :: status
  integer                             :: rank,nb_bytes_integer
  TYPE(MPI_File)                      :: fh

  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_FILE_SET_ERRHANDLER(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL)

  ! Open the file "data.dat" in read mode
  call MPI_FILE_OPEN(MPI_COMM_WORLD,"data.dat",MPI_MODE_RDONLY, &
                     MPI_INFO_NULL,fh)

  values(:)=0
  ! Read via explicit offsets, in individual mode
  call MPI_TYPE_SIZE(MPI_INTEGER,nb_bytes_integer)
  offset=rank*nb_values*nb_bytes_integer
  call MPI_FILE_READ_AT(fh,offset,values,nb_values, &
                        MPI_INTEGER,status)
  open(unit=45,file="file_dei"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rank == 0) then
    print *, 'First read done'
  end if

  values(:)=0
  ! Read via shared file pointers, in collective mode
  call MPI_FILE_READ_ORDERED(fh,values,nb_values, &
                             MPI_INTEGER,status)
  open(unit=45,file="file_ppc"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rank == 0) then
    print *, 'Second read done'
  end if

  values(:)=0
  ! Read via individual file pointer, in individual mode
  offset = rank*nb_values*nb_bytes_integer
  call MPI_FILE_SEEK(fh,offset,MPI_SEEK_SET)
  call MPI_FILE_READ(fh,values,nb_values, &
                     MPI_INTEGER,status)
  open(unit=45,file="file_pii"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rank == 0) then
    print *, 'Third read done'
  end if

  values(:)=0
  ! Read via shared file pointers, in individual mode
  ! (the shared file pointer needs to be set at the beginning of the file)
  offset=0
  call MPI_FILE_SEEK_SHARED(fh,offset,MPI_SEEK_SET)
  call MPI_FILE_READ_SHARED(fh,values,nb_values, &
                            MPI_INTEGER,status)
  open(unit=45,file="file_ppi"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rank == 0) then
    print *, 'Fourth read done'
  end if

  ! Close the file
  call MPI_FILE_CLOSE(fh)
  call MPI_FINALIZE()
end program read_file
