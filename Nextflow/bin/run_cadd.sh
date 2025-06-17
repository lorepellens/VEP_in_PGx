#!/bin/bash

set -e

# Correct shell syntax
echo "CADD: $CADD"

source activate snakemake8

INPUT_VCF=$1

${CADD} ${INPUT_VCF}

exit 0