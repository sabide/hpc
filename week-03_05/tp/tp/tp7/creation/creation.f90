! On 1 process !

program creation

  use mpi_f08

  implicit none

  integer, parameter              :: nb_values=242
  integer, dimension(2*nb_values) :: values
  type(MPI_Status)                :: status
  integer                         :: i,rank
  type(MPI_File)                  :: fh

  open(unit=45,file="carte.dat")
  ! Read X Y positions
  do i=1,nb_values
    read(45,*) values(i),values(nb_values+i)
  end do
  close(45)
  ! Values=All X positions then All Y positions

  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)
  call MPI_FILE_SET_ERRHANDLER(MPI_FILE_NULL,MPI_ERRORS_ARE_FATAL)
  call MPI_FILE_OPEN(MPI_COMM_WORLD,"data.dat",MPI_MODE_RDWR + MPI_MODE_CREATE, &
                     MPI_INFO_NULL,fh)

  call MPI_FILE_WRITE_ALL(fh,values,2*nb_values,MPI_INTEGER, &
                          status)

  call MPI_FILE_CLOSE(fh)
  call MPI_FINALIZE()

end program creation
