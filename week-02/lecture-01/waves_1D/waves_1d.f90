program wave1d_reflecting_timing
  implicit none

  !--- Double précision ---
  integer, parameter :: dp = selected_real_kind(15, 300)

  !--- Paramètres physiques ---
  real(dp), parameter :: c  = 1.0_dp   ! célérité
  real(dp), parameter :: L  = 1.0_dp   ! longueur du domaine
  real(dp), parameter :: T  = 1.0_dp   ! temps final

  !--- Discrétisation ---
  integer, parameter :: N = 1001       ! nombre de points (N > 1)
  real(dp), parameter :: dx = L / real(N - 1, dp)
  real(dp), parameter :: beta = 0.9_dp           ! c*dt/dx < 1
  real(dp), parameter :: dt   = beta * dx / c
  integer, parameter :: nt = int(T / dt)         ! nombre de pas de temps
  real(dp), parameter :: beta2 = (c * dt / dx)**2

  !--- Tableaux ---
  real(dp) :: x(N)
  real(dp) :: p_prev(N)   ! p^{n-1}
  real(dp) :: p(N)        ! p^{n}
  real(dp) :: p_next(N)   ! p^{n+1}

  !--- Divers ---
  integer :: i, nn
  real(dp) :: x0, sigma, lap

  !--- Timing ---
  integer :: count_rate, count_start, count_end
  real(dp) :: elapsed

  !========================
  ! Grille spatiale
  !========================
  do i = 1, N
     x(i) = real(i-1, dp) * dx
  end do

  !========================
  ! Conditions initiales
  ! p(x,0) = bosse gaussienne
  ! p_t(x,0) = 0
  !========================
  x0    = 0.5_dp * L
  sigma = 0.05_dp

  do i = 1, N
     p_prev(i) = exp( - ( (x(i) - x0)**2 ) / (2.0_dp * sigma**2) )
  end do

  !========================
  ! Construction de p^1 (ordre 2 en temps)
  ! p^1 = p^0 + 0.5 * dt^2 * c^2 * p_xx(x,0)
  ! ici : p_t(x,0) = 0
  !========================
  p = p_prev

  ! Bord gauche (Neumann : p_x = 0 -> p_{-1} = p_1)
  p(1) = p_prev(1) + 0.5_dp * beta2 * ( 2.0_dp * p_prev(2) - 2.0_dp * p_prev(1) )

  ! Bord droit (Neumann : p_x = 0 -> p_{N} = p_{N-2})
  p(N) = p_prev(N) + 0.5_dp * beta2 * ( 2.0_dp * p_prev(N-1) - 2.0_dp * p_prev(N) )

  ! Intérieur
  do i = 2, N-1
     lap = p_prev(i-1) - 2.0_dp * p_prev(i) + p_prev(i+1)
     p(i) = p_prev(i) + 0.5_dp * beta2 * lap
  end do

  !========================
  ! Boucle en temps (schéma saute-mouton)
  !========================

  call system_clock(count_rate = count_rate)
  call system_clock(count_start)

  do nn = 1, nt

     ! Intérieur
     do i = 2, N-1
        p_next(i) = -p_prev(i)                              &
                    + 2.0_dp * (1.0_dp - beta2) * p(i)      &
                    + beta2 * (p(i-1) + p(i+1))
     end do

     ! Bord gauche : Neumann homogène
     ! p_{-1}^n = p_1^n  =>  terme (p_{-1}^n + p_1^n) = 2 p_1^n
     p_next(1) = -p_prev(1)                                 &
                 + 2.0_dp * (1.0_dp - beta2) * p(1)         &
                 + 2.0_dp * beta2 * p(2)

     ! Bord droit : Neumann homogène
     ! p_{N}^n = p_{N-2}^n => terme (p_{N-2}^n + p_{N}^n) = 2 p_{N-2}^n
     p_next(N) = -p_prev(N)                                 &
                 + 2.0_dp * (1.0_dp - beta2) * p(N)         &
                 + 2.0_dp * beta2 * p(N-1)

     ! Rotation des niveaux de temps
     p_prev = p
     p      = p_next

  end do

  call system_clock(count_end)
  elapsed = real(count_end - count_start, dp) / real(count_rate, dp)

  !========================
  ! Résultat / sortie simple
  !========================
  write(*,'(A,I6,A,I8,A,F10.6)') 'N = ', N, ', nt = ', nt, ', temps = ', elapsed, ' s'
  write(*,'(A,F12.6)') 'p(x = L/2, t = T) = ', p(N/2)

end program wave1d_reflecting_timing

