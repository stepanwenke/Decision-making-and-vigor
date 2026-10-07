#!/bin/bash
#SBATCH --job-name=find_k
#SBATCH --time=11:00:00
#SBATCH -N1 --exclusive
#SBATCH --mem=4G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stepan.wenke@ki.se
#SBATCH --array=1-174

module load MATLAB/2024a-hpc1-bdist
MATLAB='matlab -nodesktop -nosplash -singleCompThread'
cd "/proj/vigor/users/x_stewe/real_data_modelling/recoverability/wmh/"

# Model index (change for different models, or loop externally)
model=1 
subject=${SLURM_ARRAY_TASK_ID}
echo "Array task ID = ${SLURM_ARRAY_TASK_ID}"

#for subject in $(seq 1 10); do
#    srun -n1 -N1 --exact ${MATLAB} -batch "recover_fit_K_WMH(${subject},${model});exit" > recover_fit_K_WMH_${subject}.log &
#    sleep 2 # prevent overloading the scheduler
#done
#wait # needed to prevent the script from exiting before all MATLAB tasks are done


# Uncomment for testing on a testing node
${MATLAB} -batch "recover_fit_K_WMH(${subject},${model});exit" > recover_fit_K_WMH_${subject}.log