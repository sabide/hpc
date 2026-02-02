!compute_poisson.f90
!!!!
!!subroutine initialization
!!subroutine computation
!!subroutine output_results
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MODULE compute_poisson
  USE TYPE_PARAMS
  IMPLICIT NONE

  !Coefficients
  REAL(kind=dp), DIMENSION(1:3)                           :: coef
  !Right-hand side
  REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :)              :: f

CONTAINS

  SUBROUTINE initialization(u, u_new, u_exact)  
    !**************************
    !Initialization of the values
    !**************************    
    !Solution u and u_new at the n and n+1 iterations
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(out) :: u, u_new
    !Exact solution
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(out) :: u_exact

    !Counters
    INTEGER                               :: i, j
    !Global coordinates
    REAL(kind=dp)                          :: x, y
    !Grid spacing in each dimension
    REAL(kind=dp)                          :: hx, hy 

    !Dynamic allocation of arrays u, u_new, u_exact, f
    ALLOCATE(u(sx-1:ex+1, sy-1:ey+1), &
             u_new(sx-1:ex+1, sy-1:ey+1))
    ALLOCATE(f(sx-1:ex+1, sy-1:ey+1), &
             u_exact(sx-1:ex+1, sy-1:ey+1))

    !Array initializations
    u(sx-1:ex+1, sy-1:ey+1)         = 0.
    u_new(sx-1:ex+1, sy-1:ey+1)     = 0.
    f(sx-1:ex+1, sy-1:ey+1)         = 0.
    u_exact(sx-1:ex+1, sy-1:ey+1)   = 0.

    ! Grid spacing
    hx = 1./REAL(ntx+1)
    hy = 1./REAL(nty+1)

    ! Equation Coefficients
    coef(1) = (0.5*hx*hx*hy*hy)/(hx*hx+hy*hy)
    coef(2) = 1./(hx*hx)
    coef(3) = 1./(hy*hy)

    ! Initialization of the RHS and computation of the exact solution
    DO i=sx, ex
      DO j=sy, ey
        x = i*hx
        y = j*hy
        f(i, j) = 2*(x*x-x+y*y-y)
        u_exact(i, j) = x*y*(x-1)*(y-1)
      END DO
    END DO

  END SUBROUTINE initialization


  SUBROUTINE computation(u, u_new, x1, x2, y1, y2)
    !*****************
    ! Compute u_new at the n+1 iteration
    !*****************
    ! u is the solution at the n iteration
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(in)   :: u

    !u_new is the solution at the n+1 iteration
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(inout):: u_new

    ! Local boundaries
    INTEGER, INTENT(in), OPTIONAL :: x1, x2, y1, y2

    !
    INTEGER                               :: i, j, ix1, ix2, iy1, iy2

    IF (present(y2)) THEN
      ix1 = x1
      ix2 = x2
      iy1 = y1
      iy2 = y2
    ELSE
      ix1 = sx
      ix2 = ex
      iy1 = sy
      iy2 = ey
    END IF
    DO j=iy1, iy2
      DO i=ix1, ix2
        u_new(i, j) = coef(1) * (coef(2)*(u(i+1, j)+u(i-1, j)) &
                    + coef(3)*(u(i, j+1)+u(i, j-1)) - f(i, j))
      END DO
    END DO

  END SUBROUTINE computation


  SUBROUTINE output_results(u, u_exact)  
    !**************************
    !Print
    !**************************    
    !Solution u at the n iteration
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(in) :: u
    !Exact solution
    REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :), INTENT(in) :: u_exact

    INTEGER :: j
    
    PRINT *, 'Exact solution u_exact ', 'Computed solution u'
    DO j=sy, ey
      PRINT 10, u_exact(1, j), u (1, j)
10    FORMAT('u_exact=  ', E12.5, ' u =  ', E12.5)
    END DO


  END SUBROUTINE output_results

END MODULE compute_poisson

