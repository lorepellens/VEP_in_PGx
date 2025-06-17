#!/bin/bash
#SBATCH --account=lp_h_master_thesis_volders_2025
#SBATCH --clusters=genius
#SBATCH --partition=batch   # Name of Partition
#SBATCH --job-name=nextflow_test  # Name of job
#SBATCH --output=stdout-nextflow   # Standard output name
#SBATCH --error=stderror-nextflow    # Standard Errorname
#SBATCH --ntasks=1            # Number of tasks
#SBATCH --cpus-per-task=4     # Number of CPU cores
#SBATCH --time=3-00:00:00       # Wall time (format: d-hh:mm:ss)
#SBATCH --mem=8gb            # Amount of memory (units: gb, mb, kb)
export PATH=/data/leuven/373/vsc37366/miniconda3/bin:${PATH}

module load cluster/genius/batch
module load Nextflow/23.10.0

nextflow run /staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/main.nf -c /staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/nextflow.config