#!/usr/bin/env bash
# Balayage en taille des noyaux : de « tient dans le cache » à « vient de la mémoire ».
# Usage : ./sweep.sh ./kernels > resultats.txt
# Durée : environ 1 minute.

set -euo pipefail

EXE="${1:-./kernels}"
if [[ ! -x "$EXE" ]]; then
    echo "Exécutable introuvable : $EXE" >&2
    echo "Usage : $0 ./kernels > resultats.txt" >&2
    exit 1
fi

"$EXE" fma_peak | grep -v '^#' | sed 's/^/ /' || true
echo "# --- balayage en taille (noyaux vectoriels) ---"
for k in vadd axpy dot stencil; do
    for n in 1000 10000 100000 1000000 10000000 30000000; do
        "$EXE" "$k" "$n" | grep -v '^#'
    done
done
echo "# --- produit matrice-matrice ---"
for n in 64 128 256 512; do
    "$EXE" matmul "$n" | grep -v '^#'
done
