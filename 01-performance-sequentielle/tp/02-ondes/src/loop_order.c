// loop_order.c : même calcul B = 2*A sur une matrice n x n, deux ordres de boucles.
// Usage : ./loop_order [n]     (n = 4096 par défaut)
// La matrice est stockée ligne par ligne : A[i*n + j].
#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + 1e-9 * (double)ts.tv_nsec;
}

// i extérieur, j intérieur : on avance de 1 élément (8 octets) à chaque pas
static void scale_rows(double *restrict B, const double *restrict A, int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            B[(long)i * n + j] = 2.0 * A[(long)i * n + j];
}

// j extérieur, i intérieur : on saute de n éléments (8n octets) à chaque pas
static void scale_cols(double *restrict B, const double *restrict A, int n) {
    for (int j = 0; j < n; j++)
        for (int i = 0; i < n; i++)
            B[(long)i * n + j] = 2.0 * A[(long)i * n + j];
}

// Temps minimal sur 3 essais, chacun répété pour durer au moins 50 ms
static double bench(void (*f)(double *restrict, const double *restrict, int),
                    double *B, const double *A, int n) {
    int reps = 1;
    for (;;) {
        double t0 = now();
        for (int r = 0; r < reps; r++) f(B, A, n);
        if (now() - t0 >= 0.05) break;
        reps *= 2;
    }
    double best = 1e30;
    for (int t = 0; t < 3; t++) {
        double t0 = now();
        for (int r = 0; r < reps; r++) f(B, A, n);
        double dt = (now() - t0) / reps;
        if (dt < best) best = dt;
    }
    return best;
}

int main(int argc, char **argv) {
    int n = (argc > 1) ? atoi(argv[1]) : 4096;
    if (n < 2) {
        fprintf(stderr, "Usage : %s [n]   (n >= 2, 4096 par défaut)\n", argv[0]);
        return 1;
    }
    double *A = malloc((size_t)n * n * sizeof(double));
    double *B = malloc((size_t)n * n * sizeof(double));
    if (!A || !B) { fprintf(stderr, "Erreur d'allocation\n"); return 1; }
    for (long k = 0; k < (long)n * n; k++) { A[k] = 1.0 + 1e-6 * (double)(k % 1000); B[k] = 0.0; }

    double bytes = 16.0 * n * (double)n;   // lecture de A + écriture de B
    double tr = bench(scale_rows, B, A, n);
    double tc = bench(scale_cols, B, A, n);
    printf("n=%d  par lignes : %8.3f ms %8.2f GB/s   par colonnes : %8.3f ms %8.2f GB/s   rapport=%.1f\n",
           n, tr * 1e3, bytes / tr * 1e-9, tc * 1e3, bytes / tc * 1e-9, tc / tr);
    if (B[(long)n * n / 2] < 0) printf("%g\n", B[0]);   // empêche l'élimination du calcul
    free(A); free(B);
    return 0;
}
