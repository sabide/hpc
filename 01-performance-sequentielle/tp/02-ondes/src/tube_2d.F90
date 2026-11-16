! tube_2d.F90 : équation d'onde 2D dans un tube (onde incidente non plane en x=0,
! bord absorbant en x=Lx, parois de Neumann). Le noyau de calcul est celui de la démo
! demos/fortran-2d/tube_2d_ondes.F90, inchangé.
!
! Usage : ./tube_2d [res] [t_max] [sortie]
!   res    : points par unité de longueur (50 par défaut) ; le maillage a nx = 10*res+1
!            et ny = res+1 points
!   t_max  : temps final (100 par défaut)
!   sortie : fichier du champ final (p_final.dat par défaut ; « - » : pas d'écriture)
program tube_2d_ondes
  implicit none
  !-----------------------------------------
  ! Types et constantes
  !-----------------------------------------
  integer, parameter :: dp = selected_real_kind(15, 300)

  ! Paramètres physiques
  real(dp) :: c, f, omega

  ! Domaine
  real(dp) :: Lx, Ly, dx, dy
  integer  :: nx, ny
  real(dp), allocatable :: x(:), y(:)

  ! Temps
  real(dp) :: CFL, dt, t_max, min_dxy
  integer  :: n_steps, n
  real(dp) :: t_n, t_np1

  ! Champs
  real(dp), allocatable :: p_nm1(:,:), p_n(:,:), p_np1(:,:)
  real(dp), allocatable :: g_y(:)
  real(dp) :: A, y0, sigma

  ! Boucles
  integer :: i, j, iN

  ! I/O, arguments, chronomètre
  integer :: unit_out, res, status
  character(len=64)  :: arg
  character(len=256) :: outfile
  character(len=16) :: buf_t
  integer(8) :: count_rate, count_start, count_end
  real(dp) :: elapsed

  !-----------------------------------------
  ! Paramètres physiques
  !-----------------------------------------
  c     = 1.0_dp
  f     = 5.0_dp
  omega = 2.0_dp * acos(-1.0_dp) * f   ! 2*pi*f

  !-----------------------------------------
  ! Domaine spatial : tube 2D
  !-----------------------------------------
  Lx = 10.0_dp
  Ly = 1.0_dp

  ! Arguments de la ligne de commande
  res = 50
  t_max = 100.0_dp
  outfile = 'p_final.dat'
  if (command_argument_count() >= 1) then
     call get_command_argument(1, arg)
     read(arg, *, iostat=status) res
     if (status /= 0 .or. res < 4) stop 'Usage : ./tube_2d [res>=4] [t_max] [sortie|-]'
  end if
  if (command_argument_count() >= 2) then
     call get_command_argument(2, arg)
     read(arg, *, iostat=status) t_max
     if (status /= 0 .or. t_max <= 0.0_dp) stop 'Usage : ./tube_2d [res>=4] [t_max>0] [sortie|-]'
  end if
  if (command_argument_count() >= 3) call get_command_argument(3, outfile)

  nx = int(res*Lx+1)
  ny = int(res*Ly+1)

  allocate(x(nx), y(ny))
  do i = 1, nx
     x(i) = 0.0_dp + (i-1) * Lx / real(nx-1, dp)
  end do
  do j = 1, ny
     y(j) = 0.0_dp + (j-1) * Ly / real(ny-1, dp)
  end do

  dx = x(2) - x(1)
  dy = y(2) - y(1)

  !-----------------------------------------
  ! Temps : CFL
  !-----------------------------------------
  CFL    = 0.5_dp
  min_dxy = min(dx, dy)
  dt     = CFL * min_dxy / ( c * sqrt(2.0_dp) )
  n_steps = int(t_max / dt)

  write(*,*) 'dx =', dx, ', dy =', dy, ', dt =', dt, ', n_steps =', n_steps

  !-----------------------------------------
  ! Onde incidente non plane à l'entrée x=0
  ! p(0,y,t) = g(y) sin(omega t)
  !-----------------------------------------
  A     = 1.0_dp
  y0    = Ly / 2.0_dp
  sigma = 0.05_dp * Ly

  allocate(g_y(ny))
  do j = 1, ny
     g_y(j) = A * exp( - ( (y(j) - y0)**2 ) / sigma**2 )
  end do

  !-----------------------------------------
  ! Allocation des champs : p(i,j)
  !-----------------------------------------
  allocate(p_nm1(nx, ny), p_n(nx, ny), p_np1(nx, ny))
  p_nm1 = 0.0_dp
  p_n   = 0.0_dp
  p_np1 = 0.0_dp

  !-----------------------------------------
  ! Conditions initiales
  !-----------------------------------------
  t_n = 0.0_dp
  do j = 1, ny
     p_n(1,j) = g_y(j) * sin(omega * t_n)
  end do

  do j = 1, ny
     p_nm1(1,j) = g_y(j) * sin(omega * (t_n - dt))
  end do

  !-----------------------------------------
  ! Boucle en temps
  !-----------------------------------------
  call system_clock(count_rate = count_rate)
  call system_clock(count_start)

  do n = 0, n_steps-1

     t_n   = real(n    , dp) * dt
     t_np1 = real(n + 1, dp) * dt

     ! 1) CL Dirichlet à gauche : x=0, i=1
     do j = 1, ny
        p_n(1,j) = g_y(j) * sin(omega * t_n)
     end do

     ! 2) Schéma saute-mouton à l'intérieur
     do i = 2, nx-1
        do j = 2, ny-1
           p_np1(i,j) = 2.0_dp * p_n(i,j) - p_nm1(i,j)  &
                + (c*dt)**2 * ( &
                      ( p_n(i+1,j) - 2.0_dp*p_n(i,j) + p_n(i-1,j) ) / dx**2 &
                    + ( p_n(i,j+1) - 2.0_dp*p_n(i,j) + p_n(i,j-1) ) / dy**2 )
        end do
     end do

     ! 3) Neumann horizontales : y=0 (j=1) et y=Ly (j=ny)
     do i = 1, nx
        p_np1(i,1 )  = p_np1(i,2 )
        p_np1(i,ny)  = p_np1(i,ny-1)
     end do

     ! 4) Bord droit absorbant : x=Lx, i=nx
     iN = nx
     do j = 1, ny
        p_np1(iN,j) = p_n(iN,j) - c * dt / dx * ( p_n(iN,j) - p_n(iN-1,j) )
     end do

     ! 5) Bord gauche à t_{n+1}
     do j = 1, ny
        p_np1(1,j) = g_y(j) * sin(omega * t_np1)
     end do

     ! 6) Mise à jour
     p_nm1 = p_n
     p_n   = p_np1

  end do

  call system_clock(count_end)
  elapsed = real(count_end - count_start, dp) / real(count_rate, dp)

  !-----------------------------------------
  ! Snapshot final
  !-----------------------------------------
  if (trim(outfile) /= '-') then
     open(newunit=unit_out, file=trim(outfile), status="replace", action="write", form="formatted")
     do j = 1, ny
        do i = 1, nx
           write(unit_out,'(3(1X,ES22.14E3))') x(i), y(j), p_n(i,j)
        end do
        write(unit_out,*)
     end do
     close(unit_out)
  end if

  ! Ligne de synthèse, facile à lire par un script
  write(buf_t, '(F12.3)') elapsed
  write(*,'(A,I0,A,I0,A,I0,A,I0,A,A,A)') 'res=', res, ' nx=', nx, ' ny=', ny, &
       ' n_steps=', n_steps, ' temps=', trim(adjustl(buf_t)), ' s'

  deallocate(x, y, g_y, p_nm1, p_n, p_np1)

end program tube_2d_ondes
