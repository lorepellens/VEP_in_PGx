#!/bin/bash
#SBATCH --account=lp_h_master_thesis_volders_2025
#SBATCH --clusters=genius
#SBATCH --partition=batch   # Name of Partition
#SBATCH --job-name=ensembl_VEP_test  # Name of job
#SBATCH --output=stdout-ensembl_VEP   # Standard output name
#SBATCH --error=stderror-ensampl_VEP    # Standard Errorname
#SBATCH --ntasks=1            # Number of tasks
#SBATCH --cpus-per-task=4     # Number of CPU cores
#SBATCH --time=3-00:00:00       # Wall time (format: d-hh:mm:ss)
#SBATCH --mem=8gb            # Amount of memory (units: gb, mb, kb)
export PATH=/data/leuven/373/vsc37366/miniconda3/bin:${PATH}

singularity exec \
 --bind /staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/:/Nextflow,/staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/R:/R/site-library \
  /staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/tidyverse_4.3.0.sif \
  Rscript /Nextflow/ensemble_predict.R \
    /Nextflow/combined_scores.csv \
    /Nextflow/output.csv
    