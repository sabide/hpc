#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>

int main() {
    // Paramètres physiques
    const double c      = 1.0;   // célérité
    const double L      = 1.0;   // longueur du domaine
    const double Tfinal = 1.0;   // temps final

    // Discrétisation
    const int    N   = 1001;     // nombre de points (N > 1)
    const double dx  = L / (N - 1);
    const double beta = 0.9;     // nombre de Courant: beta = c dt / dx < 1
    const double dt   = beta * dx / c;
    const int    nt   = static_cast<int>(Tfinal / dt + 0.5);
    const double beta2 = (c * dt / dx) * (c * dt / dx);

    std::vector<double> x(N);
    std::vector<double> p_prev(N);  // p^{n-1}
    std::vector<double> p(N);       // p^{n}
    std::vector<double> p_next(N);  // p^{n+1}

    // Grille
    for (int i = 0; i < N; ++i) {
        x[i] = i * dx;
    }

    // Condition initiale : bosse gaussienne au centre, vitesse initiale nulle
    const double x0    = 0.5 * L;
    const double sigma = 0.05;
    for (int i = 0; i < N; ++i) {
        double d = x[i] - x0;
        p_prev[i] = std::exp(-(d * d) / (2.0 * sigma * sigma));  // p(x,0)
    }

    // Construction de p^1 par Taylor (ordre 2 en temps, p_t(x,0)=0)
    // p^1 = p^0 + 0.5 dt^2 c^2 p_xx(x,0)
    p = p_prev; // init par défaut

    // Bord gauche (Neumann: p_x = 0 => p_{-1} = p_1)
    p[0] = p_prev[0] + 0.5 * beta2 * (2.0 * p_prev[1] - 2.0 * p_prev[0]);
    // Bord droit (Neumann: p_{N} = p_{N-2})
    p[N-1] = p_prev[N-1] + 0.5 * beta2 * (2.0 * p_prev[N-2] - 2.0 * p_prev[N-1]);

    // Intérieur
    for (int i = 1; i < N-1; ++i) {
        double lap = p_prev[i-1] - 2.0 * p_prev[i] + p_prev[i+1];
        p[i] = p_prev[i] + 0.5 * beta2 * lap;
    }

    auto t0 = std::chrono::high_resolution_clock::now();

    // Boucle en temps (schéma saute-mouton)
    for (int n = 0; n < nt; ++n) {
        // Intérieur
        for (int i = 1; i < N-1; ++i) {
            p_next[i] = -p_prev[i]
                        + 2.0 * (1.0 - beta2) * p[i]
                        + beta2 * (p[i-1] + p[i+1]);
        }

        // Bord gauche : Neumann homogène p_x=0 => p_{-1}^n = p_1^n
        p_next[0] = -p_prev[0]
                    + 2.0 * (1.0 - beta2) * p[0]
                    + 2.0 * beta2 * p[1];

        // Bord droit : Neumann homogène p_x=0 => p_{N}^n = p_{N-2}^n
        p_next[N-1] = -p_prev[N-1]
                      + 2.0 * (1.0 - beta2) * p[N-1]
                      + 2.0 * beta2 * p[N-2];

        // Rotation des niveaux de temps
        std::swap(p_prev, p);
        std::swap(p, p_next);
    }

    auto t1 = std::chrono::high_resolution_clock::now();
    double elapsed =
        std::chrono::duration<double>(t1 - t0).count();

    std::cout << "Simulation terminee : N = " << N
              << ", nt = " << nt
              << ", temps = " << elapsed << " s\n";

    // Exemple : afficher la valeur au centre à t ≈ T
    std::cout << "p(x = L/2, t = T) ≈ " << p[N/2] << "\n";

    return 0;
}
