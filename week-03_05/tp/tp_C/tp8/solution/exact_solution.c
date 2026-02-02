#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  FILE *file;
  int ntx, nty;
  double u_exact;
  double *u_calc;
  int iter, iterx, itery;
  double hx, hy;
  double x, y;
  double error,u1,u2,tmp;

  /* Reading the ntx and nty parameters */
  file = fopen("poisson.data", "r");
  if (fscanf(file, "%d", &ntx) != 1)
    ntx = 12;
  if (fscanf(file, "%d", &nty) != 1)
    nty = 10;
  fclose(file);

  /* Grid Spacing */
  hx = 1./(ntx+1);
  hy = 1./(nty+1);

  file = fopen("fort.11", "r");
  if (file == NULL) {
    fprintf(stdout, "The file is not correctly write\n");
    return 0;}

  u_calc = malloc(ntx*nty*sizeof(double));
  for (iter=0; iter<ntx*nty; iter++) {
    u_calc[iter] = 0.;
    if (fscanf(file, "%lf\n", &(u_calc[iter])) != 1) {
      fprintf(stdout, "The file is missing some data\n");
      return 0; }
  }
  fclose(file);

  /* Exact solution computation */
  error = 0;
  for (iterx=1; iterx<ntx+1; iterx++) {
    for (itery=1; itery<nty+1; itery++) {
      x = iterx*hx;
      y = itery*hy;
      u_exact = x*y*(x-1)*(y-1);
      tmp = (u_calc[ (iterx-1)*nty + itery-1] - u_exact);
      if (tmp < 0) tmp *= -1;
      if (tmp > error ) {
        error = tmp;
        u1 = u_exact;
        u2 = u_calc[ (iterx-1)*nty + itery-1];
      }
    }
  }
  fprintf(stdout, "max numeric diff %e\n", error);
  fprintf(stdout, "u_exact %e u_comp %e\n", u1 ,u2);

  if (error < 1e-6) {
    fprintf(stdout, "BRAVO, you have finished\n"); }
  else {
    fprintf(stdout, "The file is not good\n"); }

  fflush(stdout);

  free(u_calc);

  return 0;
}

