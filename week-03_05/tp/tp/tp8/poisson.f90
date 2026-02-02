!**********************************************************************
!   poisson.f90 - Solving the Poisson's equation discretized on the [0,1]x[0,1] domain
!   using the finite difference method and a Jacobi's iterative solver.
!
!   Delta u = f(x,y)= 2*(x*x-x+y*y -y)
!   u equal 0 on the boudaries
!   The exact solution is u = x*y*(x-1)*(y-1)
!
!   The u value is :
!    coef(1) = (0.5*hx*hx*hy*hy)/(hx*hx+hy*hy)
!    coef(2) = 1./(hx*hx)
!    coef(3) = 1./(hy*hy)
!
!    u(i,j)(n+1)= coef(1) * (  coef(2)*(u(i+1,j)+u(i-1,j)) &
!               + coef(3)*(u(i,j+1)+u(i,j-1)) - f(i,j))
!
!   ntx and nty are the total number of interior points along x and y, respectivly.
! 
!   hx is the grid spacing along x and hy is the grid spacing along y.
!    hx = 1./(ntx+1)
!    hy = 1./(nty+1)
!
!   On each process, we need to:
!   1) Split up the domain
!   2) Find our 4 neighbors
!   3) Exchange the interface points
!   4) Calculate u
!   5) Write the u matrix to a file (data.dat)
!
!   Author          : Isabelle DUPAYS (CNRS/IDRIS - France)
!                     <Isabelle.Dupays@idris.fr>
!   Creation        : April 2012
!****************************************************************************

PROGRAM poisson
  USE TYPE_PARAMS
  USE PARALLEL
  USE COMPUTE_POISSON

  IMPLICIT NONE

  !Solution u and u_new at the n and n+1 iterations
  REAL(kind=dp),ALLOCATABLE,DIMENSION(:, :) :: u, u_new
  !Exact solution
  REAL(kind=dp),ALLOCATABLE,DIMENSION(:, :) :: u_exact
  !Number of iterations
  INTEGER                                  :: it
  !Convergence
  REAL(kind=dp)                             :: diffnorm
  !Time measurement
  REAL(kind=dp)                             :: t1, t2
  !Convergence test
  LOGICAL                                  :: convergence

  !****************************************************************************
  !Initialization of the MPI environnement
  CALL env_init

  !Creation of the 2D Cartesian topology
  CALL topology_init

  !Compute the local grid boundary coordinates
  CALL domain_boundaries

  !Initialization of f, u, u_new and u_exact
  CALL initialization(u, u_new, u_exact)

  !Neighbours
  CALL domain_neighbours

  !Creation of the derived datatypes
  CALL derived_datatypes

  !Time stepping
  it = 0
  convergence = .FALSE.

  !Elapsed time
  t1 = MPI_WTIME()

  DO WHILE ((.NOT. convergence) .AND. (it < it_max))

    it = it +1

    u(sx:ex,sy:ey) = u_new(sx:ex,sy:ey)

    !Exchange of the interfaces at the n iteration
    CALL communications(u)

    !Computation of u at the n+1 iteration
    CALL computation(u,  u_new)

    !Computation of the global error
    diffnorm = global_error(u, u_new)

    !Stop if we obtained the machine precision using F90 funtion EPSILON
    convergence = (diffnorm < eps)

    !Print diffnorm for process 0
    IF ((rank == 0) .AND. (MOD(it,100) == 0))THEN
      PRINT *, 'Iteration ',it, ' global_error = ', diffnorm
    END IF

  END DO

  !Elapsed time
  t2 = MPI_WTIME()

  IF (rank ==  0) THEN
    !Print convergence time for process 0
    PRINT *, 'Convergence after ', it, ' iterations in  ', t2 - t1, ' seconds '

    !Compare to the exact solution on process 0
    CALL output_results(u, u_exact)
  END IF
 
  !Write the results u(sx:ex,sy:ey) 
  !on each process
  CALL write_data(u)

  !Terminates MPI execution environment
  CALL env_finalize

END PROGRAM poisson
