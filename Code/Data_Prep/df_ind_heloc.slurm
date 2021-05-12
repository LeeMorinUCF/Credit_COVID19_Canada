#!/bin/bash

#SBATCH --job-name="synth"
#SBATCH -o cr_use.out
#SBATCH -e cr_use.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --time=24:00:00
#SBATCH --mem=995G
#SBATCH -p normal

echo "Spark loading..."
module purge
module load slurm
module load sbt/0.13.15
module load anaconda2/4.3.1
module load java/1.8.0_141
module load spark/2.3.0
module list

ulimit -s unlimited
ulimit -u 81920

# AUTOMATIC CONFIGURATION
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_1011.py
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_1213.py
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_1415.py
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_1617.py
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_1819.py
smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_2021.py

smart_launch.sh -m $SLURM_MEM_PER_NODE -u $SLURM_CPUS_ON_NODE -c sortByKeyDF -n $SLURM_JOB_NUM_NODES -e 4 -p cr_use_heloc_combine.py

seff "${SLURM_JOB_ID}"
