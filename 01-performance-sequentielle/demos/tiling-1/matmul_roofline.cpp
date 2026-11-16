#include <iostream>
#include <vector>
#include <chrono>
#include <cmath>
#include <algorithm>
#include <cstdlib>   // atoi

using Clock = std::chrono::high_resolution_clock;

// Produit matrice-matrice : C = A * B
// Stockage row-major : A[i*N + j]

// Version "mauvaise" pour le cache : ordre de boucles i-j-k
void matmul_ijk(const std::vector<double>& A,
                const std::vector<double>& B,
                std::vector<double>& C,
                int N)
{
    std::fill(C.begin(), C.end(), 0.0);

    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            double sum = 0.0;
            for (int k = 0; k < N; ++k) {
                sum += A[i*N + k] * B[k*N + j];   // B parcourue en colonnes
            }
            C[i*N + j] = sum;
        }
    }
}
#include <vector>
#include <algorithm> // std::min

void matmul_tiled(const std::vector<double>& A,
                  const std::vector<double>& B,
                  std::vector<double>& C,
                  int N)
{
    // Même convention que matmul_ikj : on suppose C initialisée à 0 avant l'appel.
    // std::fill(C.begin(), C.end(), 0.0);

    const int BS = 32; // taille de bloc à ajuster suivant ta machine

    for (int ii = 0; ii < N; ii += BS) {
        const int iimax = std::min(ii + BS, N);

        for (int kk = 0; kk < N; kk += BS) {
            const int kkmax = std::min(kk + BS, N);

            for (int jj = 0; jj < N; jj += BS) {
                const int jjmax = std::min(jj + BS, N);

                // bloc (ii: iimax, jj: jjmax, kk: kkmax)
                for (int i = ii; i < iimax; ++i) {
                    for (int k = kk; k < kkmax; ++k) {
                        const double aik = A[i * N + k]; // A parcourue en lignes dans le bloc

                        for (int j = jj; j < jjmax; ++j) {
                            C[i * N + j] += aik * B[k * N + j]; // B parcourue en lignes dans le bloc
                        }
                    }
                }
            }
        }
    }
}

// Version "meilleure" pour le cache : ordre de boucles i-k-j
void matmul_ikj(const std::vector<double>& A,
                const std::vector<double>& B,
                std::vector<double>& C,
                int N)
{
    //std::fill(C.begin(), C.end(), 0.0);

    for (int i = 0; i < N; ++i) {
        for (int k = 0; k < N; ++k) {
            double aik = A[i*N + k];               // lu contigu en k
            for (int j = 0; j < N; ++j) {
                C[i*N + j] += aik * B[k*N + j];    // B parcourue en lignes
            }
        }
    }
}

int main(int argc, char** argv)
{
    int N = 1024; // taille par défaut

    if (argc >= 2) {
        N = std::atoi(argv[1]);
    }

    if (N <= 0) {
        std::cerr << "Usage: " << argv[0] << " [N]\n";
        std::cerr << "  N = taille de la matrice (N x N)\n";
        return 1;
    }

    std::cout << "Taille matrice : N = " << N << " (N x N)\n";

    std::vector<double> A(N*N), B(N*N), C(N*N);

    // Initialisation
    for (int i = 0; i < N*N; ++i) {
        A[i] = std::sin(0.001 * i);
        B[i] = std::cos(0.001 * i);
    }

    // ============ Version ijk ============

    auto t0 = Clock::now();
    matmul_ijk(A, B, C, N);
    auto t1 = Clock::now();

    double time_ijk = std::chrono::duration<double>(t1 - t0).count();

    double flops_total = 2.0 * N * N * (double)N;  // 2 N^3 FLOPs

    // Modèle "pas cache friendly" : ~ 2 N^3 doubles -> 16 N^3 bytes
    double bytes_ijk = 2.0 * N * N * (double)N * sizeof(double);
    double intensity_ijk = flops_total / bytes_ijk;        // FLOP/byte
    double gflops_ijk   = flops_total / (time_ijk * 1e9);  // GFLOP/s

    double checksum_ijk = 0.0;
    for (double v : C) checksum_ijk += v;

    std::cout << "\n=== Version ijk (mauvaise localite) ===\n";
    std::cout << "Temps           : " << time_ijk << " s\n";
    std::cout << "FLOPs total     : " << flops_total << "\n";
    std::cout << "Bytes (modele)  : " << bytes_ijk << " bytes\n";
    std::cout << "Intensite I     : " << intensity_ijk << " flop/byte\n";
    std::cout << "Perf            : " << gflops_ijk << " GFLOP/s\n";
    std::cout << "Checksum C      : " << checksum_ijk << "\n";

    // ============ Version ikj ============

    t0 = Clock::now();
    for(int rep=0;rep<1000;rep++){
    matmul_ikj(A, B, C, N);
    //matmul_tiled(A, B, C, N);
    }
    t1 = Clock::now();

    double time_ikj = std::chrono::duration<double>(t1 - t0).count()/1000;

    // Modèle GEMM optimiste : ~3 N^2 doubles -> 24 N^2 bytes
    double bytes_ikj = 3.0 * N * N * sizeof(double);
    double intensity_ikj = flops_total / bytes_ikj;        // FLOP/byte
    double gflops_ikj   = flops_total / (time_ikj * 1e9);  // GFLOP/s

    double checksum_ikj = 0.0;
    for (double v : C) checksum_ikj += v;

    std::cout << "\n=== Version ikj (meilleure localite) ===\n";
    std::cout << "Temps           : " << time_ikj << " s\n";
    std::cout << "FLOPs total     : " << flops_total << "\n";
    std::cout << "Bytes (modele)  : " << bytes_ikj << " bytes\n";
    std::cout << "Intensite I     : " << intensity_ikj << " flop/byte\n";
    std::cout << "Perf            : " << gflops_ikj << " GFLOP/s\n";
    std::cout << "Checksum C      : " << checksum_ikj << "\n";

    // Petit rappel comparatif
    std::cout << "\n=== Comparaison rapide ===\n";
    std::cout << "I_ijk / I_ikj   : " << intensity_ijk << " / " << intensity_ikj << "\n";
    std::cout << "Perf_ijk/ikj GF: " << gflops_ijk   << " / " << gflops_ikj   << "\n";

    return 0;
}

