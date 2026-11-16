#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

int main(void) {
    const double c = 1.0;
    const double L = 1.0;
    const double Tfinal = 1.0;

    int N = 1001;              // N > 1
    double dx = L / (N - 1);
    double beta = 0.9;         // c*dt/dx < 1
    double dt = beta * dx / c;
    int nt = (int)(Tfinal / dt + 0.5);
    double beta2 = (c * dt / dx) * (c * dt / dx);

    double *x      = malloc(N * sizeof(double));
    double *p_prev = malloc(N * sizeof(double));
    double *p      = malloc(N * sizeof(double));
    double *p_next = malloc(N * sizeof(double));

    if (!x || !p_prev || !p || !p_next) {
        fprintf(stderr, "Allocation error\n");
        return 1;
    }

    // Grille
    for (int i = 0; i < N; i++) {
        x[i] = i * dx;
    }

    // Condition initiale : bosse gaussienne
    double x0 = 0.5 * L;
    double sigma = 0.05;
    for (int i = 0; i < N; i++) {
        double d = x[i] - x0;
        p_prev[i] = exp(-(d * d) / (2.0 * sigma * sigma));
    }

    // Construction de p^1 (ordre 2)
    for (int i = 0; i < N; i++) {
        p[i] = p_prev[i];
    }

    // Bord gauche Neumann
    p[0] = p_prev[0] + 0.5 * beta2 * (2.0 * p_prev[1] - 2.0 * p_prev[0]);
    // Bord droit Neumann
    p[N-1] = p_prev[N-1] + 0.5 * beta2 * (2.0 * p_prev[N-2] - 2.0 * p_prev[N-1]);

    // Intérieur
    for (int i = 1; i < N-1; i++) {
        double lap = p_prev[i-1] - 2.0 * p_prev[i] + p_prev[i+1];
        p[i] = p_prev[i] + 0.5 * beta2 * lap;
    }

    clock_t t0 = clock();

    // Boucle en temps
    for (int n = 0; n < nt; n++) {
        // Intérieur
        for (int i = 1; i < N-1; i++) {
            p_next[i] = -p_prev[i]
                        + 2.0 * (1.0 - beta2) * p[i]
                        + beta2 * (p[i-1] + p[i+1]);
        }

        // Bord gauche : p_{-1}^n = p_1^n
        p_next[0] = -p_prev[0]
                    + 2.0 * (1.0 - beta2) * p[0]
                    + 2.0 * beta2 * p[1];

        // Bord droit : p_{N}^n = p_{N-2}^n
        p_next[N-1] = -p_prev[N-1]
                      + 2.0 * (1.0 - beta2) * p[N-1]
                      + 2.0 * beta2 * p[N-2];

        // Rotation des niveaux de temps
        double *tmp = p_prev;
        p_prev = p;
        p = p_next;
        p_next = tmp;
    }

    clock_t t1 = clock();
    double elapsed = (double)(t1 - t0) / CLOCKS_PER_SEC;
    printf("Simulation terminee : N=%d, nt=%d, temps = %g s\n", N, nt, elapsed);

    // Exemple : imprimer une valeur au centre
    printf("p(x=L/2, t=T) ≈ %g\n", p[N/2]);

    free(x);
    free(p_prev);
    free(p);
    free(p_next);

    return 0;
}
