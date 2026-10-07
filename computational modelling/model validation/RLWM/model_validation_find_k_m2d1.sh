#!/bin/bash
#SBATCH --job-name=model_validation_find_k_m2d1
#SBATCH --time=3:20:00
#SBATCH -N1 --exclusive
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stepan.wenke@ki.se
#SBATCH --array=1-1000

module load MATLAB/2024a-hpc1-bdist
MATLAB='matlab -nodesktop -nosplash'

# Model index (change for different models, or loop externally)
model=2
data=1

day=1
subject=${SLURM_ARRAY_TASK_ID}
echo "Array task ID = ${SLURM_ARRAY_TASK_ID}"

# Run it
${MATLAB} -batch "model_validation_fit_K_RLWM(${subject},${model},${data},${day});exit" > logs/model_validation_fit_K_RLWM${subject}.log
