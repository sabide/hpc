#!/usr/bin/env python3
"""Place les mesures de kernels sur un diagramme roofline.

Usage :
    python3 plot_roofline.py resultats.txt [--peak GFLOPS] [--bw GBS] [-o roofline.png]

Entrée : sortie de ./sweep.sh (colonnes : noyau N memoire_KB temps_ms GFLOP/s GB/s flop/octet).
  - crête de calcul : mesure de fma_peak, sauf si --peak est donné ;
  - bande passante mémoire : meilleur débit de vadd et axpy pour leur plus grande taille
    (données dans la RAM), sauf si --bw est donné.

Le tableau texte est toujours affiché ; la figure n'est produite que si matplotlib est installé.
"""
import argparse
import sys


def read(path):
    rows = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            c = line.split()
            if len(c) < 7:
                continue
            rows.append({
                "kernel": c[0], "n": int(float(c[1])), "mem_kb": float(c[2]),
                "gflops": float(c[4]), "gbs": float(c[5]), "ai": float(c[6]),
            })
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("file")
    ap.add_argument("--peak", type=float, help="crête de calcul en GFLOP/s")
    ap.add_argument("--bw", type=float, help="bande passante mémoire en GB/s")
    ap.add_argument("-o", "--output", default="roofline.png")
    a = ap.parse_args()

    rows = read(a.file)
    if not rows:
        sys.exit("Aucune mesure lue dans " + a.file)

    peak = a.peak
    if peak is None:
        pk = [r["gflops"] for r in rows if r["kernel"] == "fma_peak"]
        if not pk:
            sys.exit("Pas de ligne fma_peak : passez --peak")
        peak = max(pk)

    mem_rows = [r for r in rows if r["kernel"] in ("vadd", "axpy", "dot", "stencil")]
    bw = a.bw
    if bw is None:
        cand = []
        for k in ("vadd", "axpy"):
            ks = [r for r in rows if r["kernel"] == k]
            if ks:   # plus grande taille = données dans la RAM
                cand.append(max(ks, key=lambda r: r["mem_kb"])["gbs"])
        if not cand:
            sys.exit("Pas de ligne vadd/axpy : passez --bw")
        bw = max(cand)
    bw_cache = max([r["gbs"] for r in mem_rows] + [bw])

    ridge = peak / bw
    print(f"Crête de calcul      : {peak:8.2f} GFLOP/s")
    print(f"Bande passante (RAM) : {bw:8.2f} GB/s")
    print(f"Point de rupture     : {ridge:8.3f} flop/octet (I* = crête / bande passante)")
    print()
    print(f"{'noyau':<9}{'N':>10}{'mem(KB)':>11}{'I':>9}{'borne':>10}{'mesure':>10}{'% borne':>9}  limite")
    for r in rows:
        if r["kernel"] == "fma_peak":
            continue
        bound = min(peak, bw * r["ai"])
        limit = "mémoire" if bw * r["ai"] < peak else "calcul"
        if r["gflops"] > 1.05 * bound:
            limit += " (au-dessus du toit : données en cache)"
        print(f"{r['kernel']:<9}{r['n']:>10}{r['mem_kb']:>11.0f}{r['ai']:>9.3f}"
              f"{bound:>10.2f}{r['gflops']:>10.2f}{100 * r['gflops'] / bound:>8.0f}%  {limit}")

    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print("\nmatplotlib absent : tableau seulement (module load python, ou pip install --user matplotlib).")
        return

    fig, ax = plt.subplots(figsize=(8, 5.5))
    xs = [1e-2 * 10 ** (i / 20) for i in range(0, 20 * 5 + 1)]
    ax.loglog(xs, [min(peak, bw * x) for x in xs], "k-", lw=2.2, label="roofline (RAM)")
    if bw_cache > 1.05 * bw:
        ax.loglog(xs, [min(peak, bw_cache * x) for x in xs], "k--", lw=1.2,
                  label="meilleure bande passante mesurée (caches)")
    ax.axhline(peak, color="gray", lw=0.8, ls=":")
    ax.text(xs[-1], peak * 1.05, f"crête {peak:.0f} GFLOP/s", ha="right", va="bottom", fontsize=9)

    colors = {"vadd": "tab:blue", "axpy": "tab:orange", "dot": "tab:green",
              "stencil": "tab:red", "matmul": "tab:purple"}
    for k, col in colors.items():
        pts = sorted([r for r in rows if r["kernel"] == k], key=lambda r: r["mem_kb"])
        if not pts:
            continue
        ax.scatter([p["ai"] for p in pts], [p["gflops"] for p in pts], color=col,
                   s=[20 + 6 * (i + 1) for i in range(len(pts))], alpha=0.8, label=k)
        big = pts[-1]
        ax.annotate(k, (big["ai"], big["gflops"]), textcoords="offset points",
                    xytext=(6, -10), fontsize=9, color=col)

    ax.set_xlabel("intensité arithmétique I (flop / octet)")
    ax.set_ylabel("performance (GFLOP/s)")
    ax.set_title("Diagramme roofline (un cœur)\nla taille des points croît avec la taille du problème")
    ax.grid(True, which="both", alpha=0.25)
    ax.legend(loc="lower right", fontsize=8)
    fig.tight_layout()
    fig.savefig(a.output, dpi=150)
    print(f"\nFigure écrite : {a.output}")


if __name__ == "__main__":
    main()
