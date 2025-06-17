#!/bin/bash
set -e

alphamissense_polyphen_vcf=$1
cadd_vcf=$2
sift_vcf=$3
rscript=$4

echo "Nextflow dir: $NF_DIR"
echo "Bioconductor SIF: $R_SIF"

# Call R script from inside /work, where everything is mounted
singularity exec \
 --bind $NF_DIR:/mnt,/staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/R:/R/site-library,/staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/data/alphamissense_results/:/alphamissense_results,/staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/data/SIFT4G_results/:/SIFT4G_results,/staging/leuven/stg_00156/thesis_projects_2025/lorepellens/Nextflow/data/CADD_results/:/CADD_results $R_SIF \
  Rscript /mnt/${rscript} \
    /alphamissense_results/${alphamissense_polyphen_vcf} \
    /CADD_results/${cadd_vcf} \
    /SIFT4G_results/${sift_vcf} \
    /mnt/combined_scores.csv