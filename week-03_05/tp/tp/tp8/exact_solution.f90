PROGRAM exact_solution
  use, intrinsic :: iso_fortran_env, only : dp => real64
  IMPLICIT NONE
  !Exact solution
  REAL(kind=dp)                         :: u_exact, u1, u2, tmp
  REAL(kind=dp), ALLOCATABLE, DIMENSION(:, :) :: u_calc
  !Loop indexes
  INTEGER                               :: i, j
  !Grid coordinates
  REAL(kind=dp)                         :: x, y
  !Grid spacing
  INTEGER                               :: ntx, nty
  REAL(kind=dp)                         :: hx, hy 
  REAL(kind=dp)                         :: error
  integer                               :: ioerr

  !Reading the ntx and nty parameters
  OPEN(10, FILE='poisson.data', STATUS='OLD')
  READ(10, *) ntx
  READ(10, *) nty
  CLOSE(10)

  !Grid Spacing
  hx = 1./REAL(ntx+1)
  hy = 1./REAL(nty+1)

  ALLOCATE(u_calc(1:ntx, 1:nty))
  READ(11, 101, IOSTAT=ioerr) u_calc

  if (ioerr == 0) then
    error = 0
    DO i=1, ntx
      DO j=1, nty
        x = i*hx
        y = j*hy
        u_exact = x*y*(x-1)*(y-1)
        tmp = abs(u_calc(i,j)-u_exact)
        if (tmp > error ) then
          error = tmp
          u1 = u_exact
          u2 = u_calc(i,j)
        end if
      END DO
    END DO
    print *, "max numeric diff ", error
    print *, "u_exact u_comp", u1, u2
    if (error < 1d-6) then
      print *, "BRAVO, you have finished"
    else
      print *, "The file is not good"
    end if
  else
    print *, "The file have not the good size"
  end if

101 FORMAT  (E19.12)

END PROGRAM exact_solution

