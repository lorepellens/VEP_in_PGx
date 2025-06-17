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

source activate BCFtools

# Define Variables
# VCF=/staging/leuven/stg_00156/thesis_projects_2025/variants.vcf   # Change this to the correct VCF file path
# MY_FOLDER=/lustre1/project/stg_00156/thesis_projects_2025/lorepellens/    # Change this to your desired output directory
VEP_SIF=/lustre1/project/stg_00156/thesis_projects_2025/lorepellens/vep/vep.sif     # Path to your Singularity image
VEP_DIR=/lustre1/project/stg_00156/thesis_projects_2025/lorepellens/vep/vep_data # VEP data directory

singularity exec -B ${VEP_DIR}:/data ${VEP_SIF} \
    vep --dir data \
        --dir_cache /lustre1/project/stg_00156/thesis_projects_2025/lorepellens/vep/vep_data \
        --cache --cache_version 113 --offline --species homo_sapiens --assembly GRCh38 \
        --format vcf --vcf --force_overwrite --everything \
        --input_file /lustre1/project/stg_00156/thesis_projects_2025/lorepellens/vep/variants.vcf \
        --add-output-vcf-header \
        --output_file /lustre1/project/stg_00156/thesis_projects_2025/lorepellens/vep/output_Ensembl_VEP.vcf 

