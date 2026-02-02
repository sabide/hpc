#include <stdio.h>
#include <math.h>

int main(int argc, char *argv[]) {
  long long nbblock,i;
  double width, sum, x;

  /* Interval number */
  nbblock = 3*1000*1000LL*100;
  /* Interval width */
  width = 1.0/nbblock;

  sum = 0;

  for (i=0; i<nbblock; i++) {
    /* Point in the middle of the interval */
    x = width*(i+0.5);
    /* Compute the area */
    sum = sum + width*(4.0 / (1.0 + x*x));
  }

  printf("Pi = %.12lf\n", sum);
  printf("Difference = %g\n", sum-4.0*atan(1.0));
  
  return 0;
}
