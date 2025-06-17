#!/bin/bash

set -e

# Correct shell syntax
echo "VEP sif: $VEP_SIF"
echo "VEP DB path: $VEP_AM_DB_PATH"
echo "Cache dir: $CACHE_DIR"
echo "VEP dir: $VEP_DIR"

INPUT_VCF=$1

singularity exec \
    --bind ${VEP_DIR}:/mnt \
    ${VEP_SIF} \
    vep --dir_cache /mnt/vep \
        --cache --cache_version 113 --offline --species homo_sapiens --assembly GRCh38 \
        --format vcf --vcf --force_overwrite --everything \
        --input_file /mnt/vep/${INPUT_VCF} \
        --dir_plugins /mnt/vep \
        --plugin AlphaMissense,file=/mnt/vep/${VEP_AM_DB_PATH}\
        --output_file variants_alphamissensepredictions.vcf 

exit 0