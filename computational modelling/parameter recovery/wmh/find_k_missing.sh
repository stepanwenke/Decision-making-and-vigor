#!/bin/bash
#SBATCH --job-name=find_k
#SBATCH --time=2:00:00
#SBATCH -N1 --exclusive
#SBATCH --cpus-per-task=16 
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stepan.wenke@ki.se
#SBATCH --array=1-85

module load MATLAB/2024a-hpc1-bdist
MATLAB='matlab -nodesktop -nosplash'
cd "/proj/vigor/users/x_stewe/real_data_modelling/recoverability/wmh/"

# Model index (change for different models, or loop externally)
model=1 
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" missing_subjects.txt)
echo "Array task ID = ${subject}"

#for subject in $(seq 1 10); do
#    srun -n1 -N1 --exact ${MATLAB} -batch "recover_fit_K_WMH(${subject},${model});exit" > recover_fit_K_WMH_${subject}.log &
#    sleep 2 # prevent overloading the scheduler
#done
#wait # needed to prevent the script from exiting before all MATLAB tasks are done


# Uncomment for testing on a testing node
${MATLAB} -batch "recover_fit_K_WMH(${subject},${model});exit" > recover_fit_K_WMH_${subject}.log