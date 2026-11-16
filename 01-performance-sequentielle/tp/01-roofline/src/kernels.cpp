// kernels.cpp : micro-benchmarks pour comprendre
//   - la puissance crête d'un cœur,
//   - l'effet de l'ordre des boucles,
//   - l'effet des options de compilation,
//   - le modèle roofline.
//
// Usage :  ./kernels <noyau> [N]
//   noyaux : fma_peak | vadd | axpy | dot | stencil | matmul | scale_rows | scale_cols | all
//   N      : nombre d'éléments (noyaux vectoriels), dimension n (matmul, scale_*)
//
// Sortie : une ligne par mesure, colonnes
//   noyau  N  mémoire_KB  temps_ms  GFLOP/s  GB/s  flop/octet
//
// Les « octets » sont ceux d'un modèle idéal (chaque donnée lue ou écrite une seule fois,
// sans effet d'allocation en écriture) : ils servent à calculer l'intensité arithmétique.

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

using clk = std::chrono::steady_clock;

// Réglage de fma_peak : NV registres vectoriels de VW doubles.
// Valeurs par défaut adaptées à l'architecture ; à ajuster avec -DVW=... -DNV=...
// (par exemple -DVW=8 sur un processeur AVX-512 compilé avec -march=native).
#if defined(__aarch64__)
#  ifndef VW
#    define VW 2         // NEON : 128 bits
#  endif
#  ifndef NV
#    define NV 16
#  endif
#else
#  ifndef VW
#    define VW 4         // AVX2 : 256 bits
#  endif
#  ifndef NV
#    define NV 12
#  endif
#endif
typedef double vec __attribute__((vector_size(VW * sizeof(double))));

static volatile double sink;   // empêche le compilateur de supprimer les calculs
static volatile double seed = 0.0;  // valeur inconnue du compilateur : empêche de sortir
                                    // un appel « pur » de la boucle de répétition

static inline double seconds_since(clk::time_point t0) {
    return std::chrono::duration<double>(clk::now() - t0).count();
}

// Mesure le temps d'un appel de f : on répète assez pour durer >= 0.1 s,
// puis on garde le meilleur de 5 essais.
template <class F>
static double time_per_call(F&& f) {
    long nrep = 1;
    for (;;) {
        auto t0 = clk::now();
        for (long r = 0; r < nrep; ++r) f();
        if (seconds_since(t0) >= 0.1) break;
        nrep *= 2;
    }
    double best = 1e30;
    for (int t = 0; t < 5; ++t) {
        auto t0 = clk::now();
        for (long r = 0; r < nrep; ++r) f();
        best = std::min(best, seconds_since(t0) / nrep);
    }
    return best;
}

// ---------------------------------------------------------------------------
// Noyaux
// ---------------------------------------------------------------------------

// Calcul pur : NV registres vectoriels indépendants, a <- a*x + y, tout reste en registres.
__attribute__((noinline))
double k_fma_peak(long iters, double s0) {
    vec acc[NV];
    for (int i = 0; i < NV; ++i)
        for (int l = 0; l < VW; ++l) acc[i][l] = 1.0 + 1e-3 * (i * VW + l) + s0;
    vec x, y;
    for (int l = 0; l < VW; ++l) { x[l] = 1.0000001; y[l] = 1e-9; }
    for (long it = 0; it < iters; ++it) {
#pragma GCC unroll 16
        for (int i = 0; i < NV; ++i)
            acc[i] = acc[i] * x + y;
    }
    double s = 0.0;
    for (int i = 0; i < NV; ++i)
        for (int l = 0; l < VW; ++l) s += acc[i][l];
    return s;
}

__attribute__((noinline))
void k_vadd(double* __restrict c, const double* __restrict a, const double* __restrict b, long n) {
    for (long i = 0; i < n; ++i) c[i] = a[i] + b[i];
}

__attribute__((noinline))
void k_axpy(double* __restrict y, const double* __restrict x, double a, long n) {
    for (long i = 0; i < n; ++i) y[i] = a * x[i] + y[i];
}

__attribute__((noinline))
double k_dot(const double* __restrict x, const double* __restrict y, long n, double s0) {
    double s = s0;
    for (long i = 0; i < n; ++i) s += x[i] * y[i];
    return s;
}

// Schéma à 3 points (type équation d'onde 1D, différences finies)
__attribute__((noinline))
void k_stencil(double* __restrict un, const double* __restrict u,
               double a, double b, double c, long n) {
    for (long i = 1; i < n - 1; ++i)
        un[i] = a * u[i - 1] + b * u[i] + c * u[i + 1];
}

// Produit matrice-matrice, ordre i-k-j, stockage ligne par ligne
__attribute__((noinline))
void k_matmul(const double* __restrict A, const double* __restrict B,
              double* __restrict C, int n) {
    for (int i = 0; i < n; ++i)
        for (int k = 0; k < n; ++k) {
            const double aik = A[(long)i * n + k];
            for (int j = 0; j < n; ++j)
                C[(long)i * n + j] += aik * B[(long)k * n + j];
        }
}

// B = 2*A, parcours par lignes (contigu en mémoire) ...
__attribute__((noinline))
void k_scale_rows(double* __restrict B, const double* __restrict A, int n) {
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            B[(long)i * n + j] = 2.0 * A[(long)i * n + j];
}

// ... et parcours par colonnes (saut de n éléments à chaque pas)
__attribute__((noinline))
void k_scale_cols(double* __restrict B, const double* __restrict A, int n) {
    for (int j = 0; j < n; ++j)
        for (int i = 0; i < n; ++i)
            B[(long)i * n + j] = 2.0 * A[(long)i * n + j];
}

// ---------------------------------------------------------------------------
// Pilote
// ---------------------------------------------------------------------------

static void report(const char* name, long n, double mem_bytes, double t,
                   double flops, double bytes) {
    std::printf("%-11s %10ld %12.1f %11.4f %10.3f %9.3f %10.4f\n",
                name, n, mem_bytes / 1024.0, t * 1e3,
                flops / t * 1e-9, bytes / t * 1e-9, flops / bytes);
}

static std::vector<double> make_vec(long n, double v0) {
    std::vector<double> v(n);
    for (long i = 0; i < n; ++i) v[i] = v0 + 1e-6 * (i % 1000);
    return v;
}

static void run_fma_peak() {
    const long iters = 1L << 20;
    double t = time_per_call([&] { sink = k_fma_peak(iters, seed); });
    double flops = 2.0 * NV * VW * iters;
    report("fma_peak", NV * VW, 0.0, t, flops, 1.0);   // pas de trafic mémoire : I fictive
}

static void run_vadd(long n) {
    auto a = make_vec(n, 1.0), b = make_vec(n, 2.0), c = make_vec(n, 0.0);
    double t = time_per_call([&] { k_vadd(c.data(), a.data(), b.data(), n); sink = c[n / 2]; });
    report("vadd", n, 24.0 * n, t, 1.0 * n, 24.0 * n);
}

static void run_axpy(long n) {
    auto x = make_vec(n, 1.0), y = make_vec(n, 2.0);
    double t = time_per_call([&] { k_axpy(y.data(), x.data(), 1e-9, n); sink = y[n / 2]; });
    report("axpy", n, 16.0 * n, t, 2.0 * n, 24.0 * n);
}

static void run_dot(long n) {
    auto x = make_vec(n, 1.0), y = make_vec(n, 2.0);
    double t = time_per_call([&] { sink = k_dot(x.data(), y.data(), n, seed); });
    report("dot", n, 16.0 * n, t, 2.0 * n, 16.0 * n);
}

static void run_stencil(long n) {
    auto u = make_vec(n, 1.0), un = make_vec(n, 0.0);
    double t = time_per_call([&] { k_stencil(un.data(), u.data(), 0.25, 0.5, 0.25, n); sink = un[n / 2]; });
    report("stencil", n, 16.0 * n, t, 5.0 * (n - 2), 16.0 * n);
}

static void run_matmul(int n) {
    auto A = make_vec((long)n * n, 1.0), B = make_vec((long)n * n, 2.0);
    std::vector<double> C((long)n * n, 0.0);
    double t = time_per_call([&] { k_matmul(A.data(), B.data(), C.data(), n); sink = C[0]; });
    double flops = 2.0 * n * (double)n * n;
    report("matmul", n, 24.0 * n * n, t, flops, 24.0 * n * n);
}

static void run_scale(int n, bool rows) {
    auto A = make_vec((long)n * n, 1.0);
    std::vector<double> B((long)n * n, 0.0);
    double t = time_per_call([&] {
        if (rows) k_scale_rows(B.data(), A.data(), n);
        else      k_scale_cols(B.data(), A.data(), n);
        sink = B[(long)n * n / 2];
    });
    report(rows ? "scale_rows" : "scale_cols", n, 16.0 * n * n, t,
           1.0 * n * n, 16.0 * n * n);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage : %s <noyau> [N]\n"
            "  noyaux : fma_peak vadd axpy dot stencil matmul scale_rows scale_cols all\n", argv[0]);
        return 1;
    }
    const std::string k = argv[1];
    const bool has_n = (argc >= 3);
    const long n_vec = has_n ? std::atol(argv[2]) : 10000000L;   // noyaux vectoriels
    const int  n_mat = has_n ? std::atoi(argv[2]) : 256;         // matmul
    const int  n_2d  = has_n ? std::atoi(argv[2]) : 4096;        // scale_*

#ifdef __VERSION__
    std::printf("# compilateur : %s ; NV = %d, VW = %d\n", __VERSION__, NV, VW);
#endif
    std::printf("# %-9s %10s %12s %11s %10s %9s %10s\n",
                "noyau", "N", "memoire_KB", "temps_ms", "GFLOP/s", "GB/s", "flop/octet");

    if (k == "fma_peak")        run_fma_peak();
    else if (k == "vadd")       run_vadd(n_vec);
    else if (k == "axpy")       run_axpy(n_vec);
    else if (k == "dot")        run_dot(n_vec);
    else if (k == "stencil")    run_stencil(n_vec);
    else if (k == "matmul")     run_matmul(n_mat);
    else if (k == "scale_rows") run_scale(n_2d, true);
    else if (k == "scale_cols") run_scale(n_2d, false);
    else if (k == "all") {
        run_fma_peak();
        run_vadd(n_vec); run_axpy(n_vec); run_dot(n_vec); run_stencil(n_vec);
        run_matmul(n_mat);
    } else {
        std::fprintf(stderr, "noyau inconnu : %s\n", k.c_str());
        return 1;
    }
    return 0;
}
