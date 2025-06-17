nextflow.enable.dsl=2

process SIFT {
    tag "SIFT analysis"
    publishDir "${params.output_dir}/sift_results", mode: 'copy', pattern: '*.vcf'

    input:
    path input_vcf 

    output:
    path "variants_SIFTpredictions.vcf", emit: sift_results

    script:
    """
    export SIFT_RESULTS_DIR=${params.sift_results_dir}
    export SIFT_DB_PATH=${params.sift.db_path}
    export SIFT_ANNOTATOR_PATH=${params.sift.annotator_path}

    bash ${params.sift_script} ${input_vcf}
    """
}

process AlphaMissense_PolyPhen {
    tag "AlphaMissense analysis"
    publishDir "${params.output_dir}/alphamissense_results", mode: 'copy', pattern: '*.vcf'

    input:
    path input_vcf

    output:
    path "variants_alphamissensepredictions.vcf", emit: alphamissense_results

    script:
    """
    export VEP_SIF=${params.VEP.sif}
    export VEP_AM_DB_PATH=${params.VEP.alphamissense_db_path}
    export CACHE_DIR=${params.VEP.cache_dir}
    export VEP_DIR=${params.VEP.dir}

    bash ${params.am_pp_script} ${input_vcf}
    """
}

process CADD {
    tag "CADD analysis"
    publishDir "${params.output_dir}/CADD_results", mode: 'copy', pattern: '*.vcf'

    conda "envs/CADD_env.yaml"

    input:
    path input_vcf

    output:
    path "variants_CADDpredictions.vcf", emit: cadd_results

    script:
    """
    export ANNOVAR_DIR=${params.CADD.annovar_dir}
    export SNPEFF_DIR=${params.CADD.snpeff_dir}
    export CADD_ANNOTATIONS=${params.CADD.cadd_annotation}
    export CADD_SCRIPT_DIR=${params.CADD.cadd_script_dir}
    export CADD_MODELS=${params.CADD.cadd_models}
    export CADD=${params.CADD.cadd}

    bash ${params.cadd_script} ${input_vcf}
    """
}

process MergePredictors {
    input:
    path alphamissense_polyphen_vcf
    path cadd_vcf
    path sift_vcf 
    path merge_script

    script:
    """
    export NF_DIR=${params.nf_dir}
    export R_SIF=${params.MERGE.sif}
    export MERGE_RSCRIPT=${params.MERGE.rscript}

    bash ${params.MERGE.script} ${alphamissense_polyphen_vcf} ${cadd_vcf} ${sift_vcf} ${merge_script}
    """
}

process EnsemblePrediction {
    container 'rocker/tidyverse:latest'

    input:
    path input_scores
    path model_file from 'svm_model.RDS'  

    output:
    path "ensemble_predictions.csv"

    script:
    """
    cp $model_file ./svm_ensemble_model.rds
    Rscript ensemble_predict.R $input_scores ensemble_predictions.csv
    """
}

process ReportGeneration {
    container 'rocker/tidyverse:latest'

    input:
    path ensemble_predictions  

    output:
    path "report.html"

    script:
    """
    Rscript PGx_summary.Rmd $ensemble_predictions report.html
    """
}

workflow {
    
    def vcf_ch_AM_PP = Channel.fromPath(params.input_vcf_AM_PP)
    def vcf_ch_SIFT = Channel.fromPath(params.input_vcf_SIFT)
    def vcf_ch_CADD = Channel.fromPath(params.input_vcf_CADD)

    SIFT(vcf_ch_SIFT)
    AlphaMissense_PolyPhen(vcf_ch_AM_PP)
    CADD(vcf_ch_CADD)
    
    def output_AM_PP = Channel.fromPath(params.output_AM_PP)
    def output_SIFT = Channel.fromPath(params.output_SIFT)
    def output_CADD = Channel.fromPath(params.output_CADD)
    def rscript = Channel.fromPath(params.MERGE.rscript)
    
    MergePredictors(output_AM_PP, output_CADD, output_SIFT, rscript)

    def output_merge = Channel.fromPath(params.MERGE.output_merge)
    EnsemblePrediction(output_merge)

    def output_ensemble = Channel.fromPath(params.ENSEMBLE.output_ensemble)
    ReportGeneration(output_ensemble)

}