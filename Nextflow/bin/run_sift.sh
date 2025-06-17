#!/bin/bash

set -e

# Correct shell syntax
echo "SIFT results dir: $SIFT_RESULTS_DIR"
echo "SIFT DB path: $SIFT_DB_PATH"
echo "SIFT annotator path: $SIFT_ANNOTATOR_PATH"

INPUT_VCF=$(realpath $1)

source activate SIFT

java -jar ${SIFT_ANNOTATOR_PATH} -c -i ${INPUT_VCF} -d ${SIFT_DB_PATH} 

exit 0