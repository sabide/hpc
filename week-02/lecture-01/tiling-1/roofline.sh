#!/usr/bin/env bash

# Script : run_roofline.sh
# Usage  : ./run_roofline.sh
# Sortie : roofline_data.dat avec les colonnes :
#          N  I_ijk  Perf_ijk  I_ikj  Perf_ikj

SIZES=(4  6  8  10  12  16 32 48 64 96 128 192 256 )
OUTFILE="roofline_data.dat"

echo "# N   I_ijk[FLOP/Byte]   Perf_ijk[GFLOP/s]   I_ikj[FLOP/Byte]   Perf_ikj[GFLOP/s]" > "$OUTFILE"

for N in "${SIZES[@]}"; do
    echo ">>> N = $N"
    OUTPUT=$(mpirun -np 1 ./matmul_roofline "$N")

    # On utilise awk avec un petit automate pour distinguer les deux versions
    read I_IJK PERF_IJK I_IKJ PERF_IKJ <<< "$(echo "$OUTPUT" | awk '
        BEGIN {
            mode = ""
            Iijk = Pijk = Iikj = Pikj = "NaN"
        }

        /=== Version ijk/ { mode = "ijk" }
        /=== Version ikj/ { mode = "ikj" }

        /Intensite I/ {
            # ligne du type : "Intensite I     : 0.125 flop/byte"
            split($0, tmp, ":")
            val = tmp[2]
            gsub(/^[ \t]+/, "", val)   # trim début
            split(val, a, " ")
            if (mode == "ijk") {
                Iijk = a[1]
            } else if (mode == "ikj") {
                Iikj = a[1]
            }
        }

        /^Perf[ \t]+:/ {
            # ligne du type : "Perf            : 0.539359 GFLOP/s"
            split($0, tmp, ":")
            val = tmp[2]
            gsub(/^[ \t]+/, "", val)
            split(val, a, " ")
            if (mode == "ijk") {
                Pijk = a[1]
            } else if (mode == "ikj") {
                Pikj = a[1]
            }
        }

        END {
            print Iijk, Pijk, Iikj, Pikj
        }
    ')"

    echo "$N  $I_IJK  $PERF_IJK  $I_IKJ  $PERF_IKJ" | tee -a "$OUTFILE"
done

