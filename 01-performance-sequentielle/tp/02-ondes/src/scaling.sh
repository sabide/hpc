#!/usr/bin/env bash
# Mesure le temps d'un programme pour plusieurs tailles et estime l'exposant de complexité.
# Usage : ./scaling.sh "<commande>" N1 N2 N3 ...
# La commande doit afficher « temps=... s ». La taille est ajoutée en dernier argument ;
# si la commande contient {}, la taille est placée à cet endroit.
# Exemples :
#   ./scaling.sh ./waves_c 1001 2001 4001 8001 16001
#   ./scaling.sh "python3 waves_1d.py" 1001 2001 4001
#   ./scaling.sh "./tube_2d {} 10 -" 25 50 100 200     (2D : res, t_max = 10, pas de fichier)
set -euo pipefail

if [[ $# -lt 2 ]]; then
    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi
cmd="$1"; shift

printf "%8s %12s %9s %10s\n" "taille" "temps (s)" "rapport" "exposant"
prev_n=""; prev_t=""
for n in "$@"; do
    if [[ "$cmd" == *"{}"* ]]; then run="${cmd//\{\}/$n}"; else run="$cmd $n"; fi
    # shellcheck disable=SC2086
    t=$($run | sed -n 's/.*temps=\([0-9.eE+-]*\) s.*/\1/p')
    if [[ -z "$t" ]]; then echo "Pas de « temps=... s » dans la sortie de : $run" >&2; exit 1; fi
    awk -v n="$n" -v t="$t" -v pn="$prev_n" -v pt="$prev_t" 'BEGIN {
        if (pn == "") printf "%8d %12.6f %9s %10s\n", n, t, "-", "-";
        else           printf "%8d %12.6f %9.2f %10.2f\n", n, t, t/pt, log(t/pt)/log((n-1)/(pn-1));
    }'
    prev_n="$n"; prev_t="$t"
done
