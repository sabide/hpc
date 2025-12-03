#include <iostream>
#include <vector>
#include <chrono>
#include <cmath>
#include <algorithm>
#include <cstdlib>   // atoi

using Clock = std::chrono::high_resolution_clock;

void matmul_naive_bad(const std::vector<double>& A,
                      const std::vector<double>& B,
                      std::vector<double>& C,
                      int N)
{
    std::fill(C.begin(), C.end(), 0.0);

    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            double sum = 0.0;
            for (int k = 0; k < N; ++k) {
                sum += A[i*N + k] * B[k*N + j];  // B en colonnes -> mauvais cache
            }
            C[i*N + j] = sum;
        }
    }
}

// Version tiling pour améliorer la localisation de B et C
void matmul_tiled(const std::vector<double>& A,
                  const std::vector<double>& B,
                  std::vector<double>& C,
                  int N, int BS)
{
    std::fill(C.begin(), C.end(), 0.0);

    for (int i = 0; i < N; ++i) {
      
	  for (int kk = 0; kk < N; kk += BS) {
            int k_end = std::min(kk + BS, N);
         
	    for (int jj = 0; jj < N; jj += BS) {
                int j_end = std::min(jj + BS, N);

                for (int k = kk; k < k_end; ++k) {
                    double aik = A[i*N + k];
                    for (int j = jj; j < j_end; ++j) {
                        C[i*N + j] += aik * B[k*N + j];
                    }
                }
            }
        }
    }
}

void matmul_tiled_ijk(const std::vector<double>& A,
                      const std::vector<double>& B,
                      std::vector<double>& C,
                      int N, int BS)
{
    std::fill(C.begin(), C.end(), 0.0);

    for (int bi = 0; bi < N; bi += BS) {
        int i_end = std::min(bi + BS, N);

        for (int bj = 0; bj < N; bj += BS) {
            int j_end = std::min(bj + BS, N);

            for (int bk = 0; bk < N; bk += BS) {
                int k_end = std::min(bk + BS, N);

                // --- ordre interne: i, j, k ---
                for (int i = bi; i < i_end; ++i) {
                    for (int j = bj; j < j_end; ++j) {
                        double sum = C[i*N + j]; // accumule sur les blocs bk
                        for (int k = bk; k < k_end; ++k) {
                            sum += A[i*N + k] * B[k*N + j];
                        }
                        C[i*N + j] = sum;
                    }
                }
            }
        }
    }
}


int main(int argc, char** argv)
{
    // Valeurs par défaut
    int N  = 1024;   // taille de la matrice
    int BS = 16;     // taille de bloc (tile size)

    if (argc >= 2) {
        N = std::atoi(argv[1]);
    }
    if (argc >= 3) {
        BS = std::atoi(argv[2]);
    }

    if (N <= 0 || BS <= 0) {
        std::cerr << "Usage: " << argv[0] << " [N] [BS]\n";
        std::cerr << "  N  = taille de la matrice (N x N)\n";
        std::cerr << "  BS = taille du bloc (tile size)\n";
        return 1;
    }

    std::cout << "N = " << N << ", BS = " << BS << "\n";

    std::vector<double> A(N*N), B(N*N), C(N*N);

    // Initialisation
    for (int i = 0; i < N*N; ++i) {
        A[i] = std::sin(0.001 * i);
        B[i] = std::cos(0.001 * i);
    }

    // ----- Naive "mauvais cache" -----
    auto t0 = Clock::now();
    matmul_naive_bad(A, B, C, N);
    auto t1 = Clock::now();
    double t_naive = std::chrono::duration<double>(t1 - t0).count();
    double cs_naive = 0.0;
    for (double v : C) cs_naive += v;
    std::cout << "Temps naive : " << t_naive << " s\n";

    // ----- Tiled -----
    t0 = Clock::now();
    matmul_tiled_ijk(A, B, C, N, BS);
    t1 = Clock::now();
    double t_tiled = std::chrono::duration<double>(t1 - t0).count();
    double cs_tiled = 0.0;
    for (double v : C) cs_tiled += v;
    std::cout << "Temps tiled : " << t_tiled << " s\n";

    std::cout << "checksum naive = " << cs_naive  << "\n";
    std::cout << "checksum tiled = " << cs_tiled  << "\n";
    std::cout << "Rapport (naive / tiled) = " << t_naive / t_tiled << "\n";

    return 0;
}

