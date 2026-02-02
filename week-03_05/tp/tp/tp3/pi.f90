program pi
  use, intrinsic :: iso_fortran_env, only : dp => real64, li => int64
  implicit none
  integer(kind=li)   :: nbblock,i,begin,end
  real(kind=dp)      :: width,sum,global,x

  ! Interval number
  nbblock = 3*1000*1000_li*100
  ! Interval width
  width = 1._dp / real(nbblock,dp)

  sum = 0._dp

  do i=1, nbblock
    ! Point in the middle of the interval
    x = width*(i-0.5_dp)
    ! Compute the area
    sum = sum + width*(4._dp / (1._dp + x*x))
  end do

  print *, "Pi =", sum
  print *, "Difference =", sum-4._dp*atan(1._dp)
end program
