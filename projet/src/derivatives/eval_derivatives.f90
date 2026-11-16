program deriv2_3d
    use mpi
    use decomp_2d
    implicit none

    integer :: Nx, Ny, Nz
    integer :: i, j, k, ierr
    integer :: p_row,p_col
    real(kind=8), allocatable :: fi(:, :, :), lap_fi(:, :, :)
    real(kind=8) :: dx,dy,dz
    
    ! Taille globale du domaine
    Nx = 128
    Ny = 128
    Nz = 128
    p_row= 4
    p_col= 4

    dx = 1.0 / Nx  ! Supposons un domaine normalisé [0,1]
    dy = 1.0 / Ny 
    dz = 1.0 / Nz 
    ! Initialisation MPI et decomp_2d
    call MPI_Init(ierr)

    call decomp_2d_init(nx,ny,nz,p_row,p_col)
    ! Allocation des tableaux locaux
    allocate(fi(xstart(1):xend(1),xstart(2):xend(2),xstart(3):xend(3) ))
    allocate(lap_fi(xstart(1):xend(1),xstart(2):xend(2),xstart(3):xend(3) ))
    
    ! Initialisation du champ (par exemple, une sinusoïde)
    do k = xstart(3),xend(3)
        do j = xstart(2),xend(2)
            do i = xstart(1),xend(1)
                fi(i, j, k) = i+j+k
            end do
        end do
    end do

    ! Calcul de la dérivée seconde en x avec différences finies centrées
    ! d'ordre 2

    ! Finalisation MPI et decomp_2d
    call decomp_2d_finalize()
    call MPI_Finalize(ierr)

end program deriv2_3d

