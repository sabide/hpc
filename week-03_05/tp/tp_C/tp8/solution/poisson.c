/*
 *   poisson.f90 - Solving the Poisson's equation discretized on the [0,1]x[0,1] domain
 *   using the finite difference method and a Jacobi's iterative solver.
 *
 *   Delta u = f(x,y)= 2*(x*x-x+y*y -y)
 *   u equal 0 on the boudaries
 *   The exact solution is u = x*y*(x-1)*(y-1)
 *
 *   The u value is :
 *    coef(1) = (0.5*hx*hx*hy*hy)/(hx*hx+hy*hy)
 *    coef(2) = 1./(hx*hx)
 *    coef(3) = 1./(hy*hy)
 *
 *    u(i,j)(n+1)= coef(1) * (  coef(2)*(u(i+1,j)+u(i-1,j)) &
 *               + coef(3)*(u(i,j+1)+u(i,j-1)) - f(i,j))
 *
 *   ntx and nty are the total number of interior points along x and y, respectivly.
 * 
 *   hx is the grid spacing along x and hy is the grid spacing along y.
 *    hx = 1./(ntx+1)
 *    hy = 1./(nty+1)
 *
 *   On each process, we need to:
 *   1) Split up the domain
 *   2) Find our 4 neighbors
 *   3) Exchange the interface points
 *   4) Calculate u
 *   5) Write the u matrix to a file (data.dat)
 *
 *   Author          : Dimitri Lecas  (CNRS/IDRIS - France)
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>

#include "parallel.h"
#include "params.h"
#include "compute.h"

int main(int argc, char *argv[]) {
  /* Solution u and u_new at the n and n+1 iterations */
  double *u, *u_new;
  /* Exact solution */
  double *u_exact;
  /* Number of iterations */
  int it;
  /* Time measurement */
  double t1, t2;
  /* Temporary pointer to swap u and u_new */
  double *temp;
  /* Convergence test */
  double diffnorm;
  int convergence;

  /* Initialization of the MPI environnement */
  env_init(argc, argv);

  /* Creation of the 2D Cartesian topology */
  topology_init();

  /* Compute the local grid boundary coordinates */
  domain_boundaries();

  /* Initialization of f, u, u_new and u_exact */
  initialization(&u, &u_new, &u_exact);

  /* Neighbours */
  domain_neighbours();

  /* Creation des types derives type_line et type_column */
  derived_datatypes();

  /* Time stepping */
  it = 0;
  convergence = false;

  /* Elapsed time */
  t1 = MPI_Wtime();

  while (!(convergence) && (it < it_max)) {
    it = it+1;

    temp = u; u = u_new; u_new = temp;

    /* Exchange of the interfaces at the n iteration */
    communications(u);

    /* Computation of u at the n+1 iteration */
    computation(u, u_new);

    /* Computation of the global error */
    diffnorm = global_error(u, u_new);

    /* Stop if we obtained the machine precision */
    convergence = (diffnorm < eps);

    /* Print diffnorm for process 0 */
    if ((rank == 0) && ((it % 100) == 0))
      printf("Iteration %d global_error = %g\n", it, diffnorm);
  }

  /* Elapsed time */
  t2 = MPI_Wtime();

  if (rank == 0) {
    /* Print convergence time for process 0 */
    printf("Convergence after %d iterations in %f secs\n", it, t2-t1);

    /* Compare to the exact solution on process 0 */
    output_results(u, u_exact);
  }

  /* Write the results u(sx:ex,sy:ey)
   * on each process */
  write_data(u);

  /* Free dynamically allocated memory */
  free(u);
  free(u_new);
  free(u_exact);
  /* free(f); */

  /* Terminates MPI execution environment */
  env_finalize();

  return 0;
}
