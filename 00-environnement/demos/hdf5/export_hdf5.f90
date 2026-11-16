program export_hdf5
  use hdf5
  implicit none

  ! Variables HDF5
  INTEGER(HID_T) :: FILE_ID, DATASET_ID, DATASPACE_ID
  INTEGER(KIND=HSIZE_T), DIMENSION(3) :: DIMS
  INTEGER :: STATUS
  REAL(KIND=8), ALLOCATABLE :: DATA(:,:,:)
  INTEGER :: NX, NY, NZ, I, J, K

  ! Dimensions du champ 3D
  nx = 10
  ny = 10
  nz = 10

  ! Allocation et initialisation du champ 3D
  allocate(data(nx, ny, nz))
  do k = 1, nz
     do j = 1, ny
        do i = 1, nx
           data(i, j, k) = real(i * j * k, kind=8)
        end do
     end do
  end do

  ! Définition des dimensions pour l'espace de données HDF5
  dims = [nx, ny, nz]


  CALL H5OPEN_F( status )
  ! Création du fichier HDF5
  CALL H5FCREATE_F("field3d.h5",H5F_ACC_TRUNC_F, file_id, status)
  ! Création de l'espace de données
  call h5screate_simple_f(3, dims, dataspace_id, status)
  ! Création du dataset
  call h5dcreate_f(file_id, "T", H5T_NATIVE_DOUBLE, dataspace_id, dataset_id, status)
  ! Écriture des données dans le dataset
  call h5dwrite_f(dataset_id, H5T_NATIVE_DOUBLE, data, dims, status)
  
  ! Fermeture des objets HDF5
  call h5dclose_f(dataset_id, status)
  call h5sclose_f(dataspace_id, status)
  call h5fclose_f(file_id, status)

  ! Libération de la mémoire
  deallocate(data)


end program export_hdf5
