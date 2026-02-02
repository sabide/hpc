#!/bin/bash
#SBATCH --job-name=read_file
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=00:01:00
#SBATCH --output=read_file-%j.out
#SBATCH --error=read_file-%j.out
#SBATCH --hint=nomultithread
#SBATCH --account=training

cd ${SLURM_SUBMIT_DIR}
 
module purge
 
module load intel/2025.2.0 impi/2021.16
set -x
 
mpirun -bootstrap slurm -n $SLURM_NTASKS ./read_file
