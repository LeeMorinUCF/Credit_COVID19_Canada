#!/bin/bash

#SBATCH --job-name="MOP"
#SBATCH -o MOP.out
#SBATCH -e MOP.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --time=24:00:00
#SBATCH --mem=240G
#SBATCH -p normal

echo "Spark loading..."
module purge
module load slurm
module load sbt
module load anaconda2/4.3.1
module load java/1.8.0_141
module load spark/2.3.0
module load R
module list

ulimit -s unlimited
ulimit -u 81920

# AUTOMATIC CONFIGURATION
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p TU_vs_Nilson_comp.py

rm TU_vs_BoC_num_accts.csv
awk 'FNR==1&&NR!=1{next;}{print}' df_ind_folder/*.csv >> TU_vs_BoC_num_accts.csv
rm -r df_ind_folder

seff "${SLURM_JOB_ID}"
