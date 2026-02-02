#ifndef PARAMS_H
#define PARAMS_H

/* Number of points on each dimension */
extern int ntx, nty;

/* Local grid boundary coordinates (global indexes) */
extern int sx, ex, sy, ey;

/* Number of time step iteration */
#define it_max 100000

/* Epsilon function */
#define eps 2.e-16

#define false 0

#endif
