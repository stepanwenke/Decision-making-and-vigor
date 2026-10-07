#!/bin/bash
#SBATCH --job-name=fit_WMH_array
#SBATCH --time=3-1:00:00
#SBATCH -N1 --exclusive
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stepan.wenke@ki.se

# Define the range of iterations (1 to 10)
#SBATCH --array=1-10

module load MATLAB/2024a-hpc1-bdist
MATLAB='matlab -nodesktop -nosplash'
cd "/proj/vigor/users/x_stewe/real_data_modelling/recoverability/wmh/"

# Capture the array task ID (1, 2, ..., 10)
TASK_ID=$SLURM_ARRAY_TASK_ID

echo "Starting iteration $TASK_ID..."

# Pass the TASK_ID to the MATLAB function
${MATLAB} -batch "recover_fit_WMH($TASK_ID)" > "recover_fit_WMH_ite${TASK_ID}.log" 2>&1

echo "Finished iteration $TASK_ID."