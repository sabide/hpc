! waves_1d_rot.f90 (corrigé du TP C) : waves_1d.f90 avec rotation des allocations au lieu de recopies.
!
! waves_1d.f90 : équation d'onde 1D, schéma saute-mouton, bords de Neumann.
! Usage : ./waves_f [N]     (N >= 3 points, 1001 par défaut)
! Sortie : une ligne  N=... nt=... temps=... s p(L/2)=...
program waves_1d
  implicit none
  integer, parameter :: dp = selected_real_kind(15, 300)

  real(dp), parameter :: c = 1.0_dp       ! célérité
  real(dp), parameter :: L = 1.0_dp       ! longueur du domaine
  real(dp), parameter :: T = 1.0_dp       ! temps final
  real(dp), parameter :: beta = 0.9_dp    ! nombre de Courant : c*dt/dx < 1

  integer  :: N, nt, i, nn, status
  real(dp) :: dx, dt, beta2, x0, sigma, lap, elapsed
  real(dp), allocatable :: x(:), p_prev(:), p(:), p_next(:), tmp(:)
  integer(8) :: count_rate, count_start, count_end
  character(len=32) :: arg
  character(len=16) :: buf_t, buf_p

  N = 1001
  if (command_argument_count() >= 1) then
     call get_command_argument(1, arg)
     read(arg, *, iostat=status) N
     if (status /= 0 .or. N < 3) stop 'Usage : ./waves_f [N]   (N >= 3, 1001 par defaut)'
  end if

  dx    = L / real(N - 1, dp)
  dt    = beta * dx / c
  nt    = int(T / dt + 0.5_dp)
  beta2 = (c * dt / dx)**2

  allocate(x(N), p_prev(N), p(N), p_next(N))

  do i = 1, N
     x(i) = real(i - 1, dp) * dx
  end do

  ! Condition initiale : bosse gaussienne, vitesse initiale nulle
  x0 = 0.5_dp * L
  sigma = 0.05_dp
  do i = 1, N
     p_prev(i) = exp(-((x(i) - x0)**2) / (2.0_dp * sigma**2))
  end do

  ! Construction de p^1 (ordre 2)
  p(1) = p_prev(1) + 0.5_dp * beta2 * (2.0_dp * p_prev(2) - 2.0_dp * p_prev(1))
  p(N) = p_prev(N) + 0.5_dp * beta2 * (2.0_dp * p_prev(N-1) - 2.0_dp * p_prev(N))
  do i = 2, N - 1
     lap = p_prev(i-1) - 2.0_dp * p_prev(i) + p_prev(i+1)
     p(i) = p_prev(i) + 0.5_dp * beta2 * lap
  end do

  call system_clock(count_rate = count_rate)
  call system_clock(count_start)

  do nn = 1, nt
     do i = 2, N - 1
        p_next(i) = -p_prev(i)                           &
                    + 2.0_dp * (1.0_dp - beta2) * p(i)   &
                    + beta2 * (p(i-1) + p(i+1))
     end do
     ! Bords de Neumann
     p_next(1) = -p_prev(1) + 2.0_dp * (1.0_dp - beta2) * p(1) + 2.0_dp * beta2 * p(2)
     p_next(N) = -p_prev(N) + 2.0_dp * (1.0_dp - beta2) * p(N) + 2.0_dp * beta2 * p(N-1)

     ! Rotation des niveaux de temps
     ! Rotation des allocations : aucune recopie de données (comme la rotation de pointeurs en C)
     call move_alloc(p_prev, tmp)
     call move_alloc(p,      p_prev)
     call move_alloc(p_next, p)
     call move_alloc(tmp,    p_next)
  end do

  call system_clock(count_end)
  elapsed = real(count_end - count_start, dp) / real(count_rate, dp)

  ! N impair : le centre est le point d'indice (N+1)/2 (indexation depuis 1)
  write(buf_t, '(F12.6)') elapsed
  write(buf_p, '(F12.6)') p((N+1)/2)
  write(*, '(A,I0,A,I0,A,A,A,A)') 'N=', N, ' nt=', nt, ' temps=', trim(adjustl(buf_t)), &
        ' s p(L/2)=', trim(adjustl(buf_p))

  deallocate(x, p_prev, p, p_next)
end program waves_1d
