program fd_p2p
  USE MPI_F08
  implicit none
  
  TYPE(MPI_Status)                     :: status
  integer :: tag,tag_r,tag_l
  
  integer :: i,is,ie,n_loc,n_glb
  integer  :: rank,nb_proc,nb_node_per_proc
  real(kind=8),dimension(:),allocatable :: x,fi,dfi
  real(kind=8) :: h
  integer :: rank_l,rank_r
  
  character(len=50) :: filename
  character(len=3) :: NUM
  integer :: file_unit

  real(kind=8),parameter :: pi=acos(-1.)
  
  call MPI_INIT()

  call MPI_COMM_SIZE(MPI_COMM_WORLD,nb_proc)
  call MPI_COMM_RANK(MPI_COMM_WORLD,rank)

  n_loc = 48
  n_glb = n_loc*nb_proc

  h = 10./ real(n_glb)
  
  ! global index rang
  is = rank*n_loc + 1
  ie = is + n_loc - 1
!  print*,rank,is,ie
  
  allocate( x(is-1:ie+1) ) ; x = 0 ;
  allocate( fi(is-1:ie+1) ) ; fi = 0 ;
  allocate(dfi(is-1:ie+1) ) ; dfi = 0 ;
  
  rank_l = mod( rank-1 + nb_proc  , nb_proc )
  rank_r = mod( rank+1            , nb_proc )
  
  do i=is,ie
     x(i) = (i-1)*h
  end do

  do i=is,ie
     fi(i) = cos(2*pi*x(i))/(4*pi**2)
  end do
! 

  tag_r = 1000 + rank_r
  tag_l = 1000 + rank
  CALL MPI_SEND(fi(ie  ),1,MPI_REAL8,rank_r,TAG_r, MPI_COMM_WORLD)        ! i send to rank 1
  CALL MPI_RECV(fi(is-1),1,MPI_REAL8,rank_l,TAG_l, MPI_COMM_WORLD,STATUS) ! i receive from 1

  tag_l = 1000 + rank_l
  tag_r = 1000 + rank 
  CALL MPI_SEND(fi(is  ),1,MPI_REAL8,rank_l,TAG_l, MPI_COMM_WORLD)        ! i send to rank 1
  CALL MPI_RECV(fi(ie+1),1,MPI_REAL8,rank_r,TAG_r, MPI_COMM_WORLD,STATUS) ! i receive from 1

  
  do i=is,ie
     dfi(i) = (fi(i-1)-2*fi(i)+fi(i+1))/h**2
  end do
  
  file_unit = rank + 1000
  write(num, '(I3.3)')rank
  filename = "data/out_"//num//".dat"
  !file_unit = 100 + rank  ! Attribuer un numéro d'unité unique pour chaque processus
  
  open(unit=file_unit, file=filename)
  do i=is,ie
     write(file_unit,'(2(e15.8,1x))')x(i),dfi(i)
  end do
  close(file_unit)
  
  
  
  call mpi_finalize()




  

  end program fd_p2p
