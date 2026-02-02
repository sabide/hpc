#include <stdlib.h>
#include <stdio.h>

#include "compute.h"
#include "params.h"

/* RHS */
static double *f;
/* Coefs */
static double coef[3];

/*
 * u : nb of line = ex-sx+3 nb of column = ey-sy+3
 */

#define IDX(i, j) ( ((i)-(sx-1))*(ey-sy+3) + (j)-(sy-1) )

void initialization(double **pu, double **pu_new, double **pu_exact) {
  /* Grid spacing in each dimension */
  double hx, hy;
  /* Global coordinates */
  double x, y; 

  int iterx, itery;

  /* Solution u and u_new at the n and n+1 iterations */
  *pu = calloc( (ex-sx+3) * (ey-sy+3), sizeof(double));
  *pu_new = calloc( (ex-sx+3) * (ey-sy+3), sizeof(double));

  /* Exact solution */
  *pu_exact = calloc( (ex-sx+3) * (ey-sy+3), sizeof(double));

  f = calloc( (ex-sx+3) * (ey-sy+3), sizeof(double));

  /* Grid spacing */
  hx = 1/(ntx+1.);
  hy = 1/(nty+1.);

  /* Equation Coefficients */
  coef[0] = (0.5*hx*hx*hy*hy)/(hx*hx+hy*hy);
  coef[1] = 1./(hx*hx);
  coef[2] = 1./(hy*hy);

  /* Initialization of the RHS and computation of the exact solution */
  for(iterx=sx; iterx<ex+1; iterx++) {
    for (itery=sy; itery<ey+1; itery++) {
      x = iterx*hx;
      y = itery*hy;
      f[IDX(iterx, itery)] = 2*(x*x-x+y*y-y);
      (*pu_exact)[IDX(iterx, itery)] = x*y*(x-1)*(y-1);
    }
  }
}

/*
 * Compute u_new at the n+1 iteration
 */
void computation(double *u, double *u_new) {
  int iterx, itery;

  for (iterx=sx; iterx<ex+1; iterx++) {
    for (itery=sy; itery<ey+1; itery++) {
      u_new[IDX(iterx, itery)] =
        coef[0] * (  coef[1]*(u[IDX(iterx+1, itery)]+u[IDX(iterx-1, itery)])
                   + coef[2]*(u[IDX(iterx, itery+1)]+u[IDX(iterx, itery-1)])
        - f[IDX(iterx, itery)]);
    }
  }
}

/*
 * Print
 */
void output_results(double *u, double *u_exact) {
  int itery;

  printf("Exact Solution u_exact - Computed Solution u\n");
  for(itery=sy; itery<ey+1; itery++)
    printf("%12.5e - %12.5e\n", u_exact[IDX(1, itery)], u[IDX(1, itery)]);
}
