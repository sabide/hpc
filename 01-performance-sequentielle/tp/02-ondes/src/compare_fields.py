#!/usr/bin/env python3
"""Compare deux champs p_final.dat (colonnes x, y, p) : écart maximal en valeur absolue.

Usage : python3 compare_fields.py a.dat b.dat
Python standard uniquement (pas besoin de NumPy).
"""
import sys


def read(path):
    vals = []
    with open(path) as f:
        for line in f:
            c = line.split()
            if len(c) == 3:
                vals.append(float(c[2]))
    return vals


if len(sys.argv) != 3:
    sys.exit(__doc__)
a, b = read(sys.argv[1]), read(sys.argv[2])
if len(a) != len(b):
    sys.exit(f"Tailles différentes : {len(a)} et {len(b)} points")
err = max(abs(u - v) for u, v in zip(a, b))
ref = max(abs(u) for u in a)
print(f"{len(a)} points ; max|p| = {ref:.6g} ; écart maximal = {err:.3e} ; écart relatif = {err / ref:.3e}")
