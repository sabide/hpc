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

  ! TODO: Open the file "data.dat" in read mode

  values(:)=0
  ! TODO: Read via explicit offsets, in individual mode

  open(unit=45,file="file_dei"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rank == 0) then
    print *, 'First read done'
  end if

  values(:)=0
  ! TODO: Read via shared file pointers, in collective mode

  open(unit=45,file="file_ppc"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rank == 0) then
    print *, 'Second read done'
  end if

  values(:)=0
  ! TODO: Read via individual file pointer, in individual mode

  open(unit=45,file="file_pii"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rang == 0) then
    print *, 'Third read done'
  end if

  values(:)=0
  ! TODO: Read via shared file pointers, in individual mode

  open(unit=45,file="file_ppi"//achar(48+rank)//".dat")
  write(unit=45,fmt='(I3)') values(:)
  close(unit=45)
  call MPI_BARRIER(MPI_COMM_WORLD)
  if (rang == 0) then
    print *, 'Fourth read done'
  end if

  ! TODO: Close the file

  call MPI_FINALIZE()
end program read_file
