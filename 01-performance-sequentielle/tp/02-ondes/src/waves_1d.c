// waves_1d.c : équation d'onde 1D, schéma saute-mouton, bords de Neumann.
// Usage : ./waves_c [N]     (N >= 3 points, 1001 par défaut)
// Sortie : une ligne  N=... nt=... temps=... s p(L/2)=...
#define _POSIX_C_SOURCE 199309L
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + 1e-9 * (double)ts.tv_nsec;
}

int main(int argc, char **argv) {
    const double c = 1.0;      // célérité
    const double L = 1.0;      // longueur du domaine
    const double Tfinal = 1.0; // temps final

    int N = (argc > 1) ? atoi(argv[1]) : 1001;
    if (N < 3) {
        fprintf(stderr, "Usage : %s [N]   (N >= 3, 1001 par défaut)\n", argv[0]);
        return 1;
    }
    const double dx = L / (N - 1);
    const double beta = 0.9;   // nombre de Courant : c*dt/dx < 1
    const double dt = beta * dx / c;
    const int nt = (int)(Tfinal / dt + 0.5);
    const double beta2 = (c * dt / dx) * (c * dt / dx);

    double *x      = malloc(N * sizeof(double));
    double *p_prev = malloc(N * sizeof(double));
    double *p      = malloc(N * sizeof(double));
    double *p_next = malloc(N * sizeof(double));
    if (!x || !p_prev || !p || !p_next) {
        fprintf(stderr, "Erreur d'allocation\n");
        return 1;
    }

    for (int i = 0; i < N; i++) x[i] = i * dx;

    // Condition initiale : bosse gaussienne, vitesse initiale nulle
    const double x0 = 0.5 * L, sigma = 0.05;
    for (int i = 0; i < N; i++) {
        double d = x[i] - x0;
        p_prev[i] = exp(-(d * d) / (2.0 * sigma * sigma));
    }

    // Construction de p^1 (ordre 2)
    p[0]     = p_prev[0]     + 0.5 * beta2 * (2.0 * p_prev[1]     - 2.0 * p_prev[0]);
    p[N - 1] = p_prev[N - 1] + 0.5 * beta2 * (2.0 * p_prev[N - 2] - 2.0 * p_prev[N - 1]);
    for (int i = 1; i < N - 1; i++) {
        double lap = p_prev[i - 1] - 2.0 * p_prev[i] + p_prev[i + 1];
        p[i] = p_prev[i] + 0.5 * beta2 * lap;
    }

    double t0 = now();

    // Boucle en temps
    for (int n = 0; n < nt; n++) {
        for (int i = 1; i < N - 1; i++) {
            p_next[i] = -p_prev[i]
                        + 2.0 * (1.0 - beta2) * p[i]
                        + beta2 * (p[i - 1] + p[i + 1]);
        }
        // Bords de Neumann : p_{-1}^n = p_1^n  et  p_N^n = p_{N-2}^n
        p_next[0]     = -p_prev[0]     + 2.0 * (1.0 - beta2) * p[0]     + 2.0 * beta2 * p[1];
        p_next[N - 1] = -p_prev[N - 1] + 2.0 * (1.0 - beta2) * p[N - 1] + 2.0 * beta2 * p[N - 2];

        // Rotation des niveaux de temps
        double *tmp = p_prev;
        p_prev = p;
        p = p_next;
        p_next = tmp;
    }

    double elapsed = now() - t0;
    printf("N=%d nt=%d temps=%.6f s p(L/2)=%.6f\n", N, nt, elapsed, p[N / 2]);

    free(x); free(p_prev); free(p); free(p_next);
    return 0;
}
