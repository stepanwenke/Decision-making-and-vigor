#!/bin/bash
#SBATCH --job-name=model_validation_find_k_missing
#SBATCH --time=4:00:00
#SBATCH -N1 --exclusive
#SBATCH --cpus-per-task=16 
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stepan.wenke@ki.se
#SBATCH --array=1-36

module load MATLAB/2024a-hpc1-bdist
MATLAB='matlab -nodesktop -nosplash'

#cd "/proj/vigor/users/x_stewe/real_data_modelling/model validation/RLWM/"

# Model index (change for different models, or loop externally)
model=1
data=2
day=1
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" missing_subjects.txt)
echo "Array task ID = ${subject}"

# Run it
#${MATLAB} -batch "model_validation_fit_K_RLWM(${subject},${model},${data},${day});exit" > logs/model_validation_fit_K_RLWM${subject}.log

${MATLAB} -batch "model_validation_fit_K_RLWM(${subject},${model},${data},${day});exit" \
  > output/model_validation_fit_K_RLWM${subject}.out \
  2> logs/model_validation_fit_K_RLWM${subject}.log