#!/usr/bin/env Rscript

# Set up library path
lib <- "/R/site-library"
if (!dir.exists(lib)) dir.create(lib, recursive = TRUE)
.libPaths(lib)

# Load/install required packages
packages <- c("VariantAnnotation", "dplyr", "tidyr", "stringr", "readxl", "purrr", "data.table")
for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (pkg %in% c("VariantAnnotation")) {
      BiocManager::install(pkg, lib = lib, ask = FALSE)
    } else {
      install.packages(pkg, lib = lib, repos = "https://cloud.r-project.org")
    }
  }
  library(pkg, character.only = TRUE)
}

# Command-line arguments
args <- commandArgs(trailingOnly = TRUE)
AM_PP_vcf   <- args[1]
cadd_vcf    <- args[2]
sift_vcf   <- args[3]
output_csv  <- args[4]

# Helper function: extract CSQ annotations as data.frame
extract_csq_df <- function(vcf_path) {
  vcf <- readVcf(vcf_path, genome = "GRCh38")
  csq_header <- info(header(vcf))["CSQ", "Description"]
  csq_fields <- str_match(csq_header, "Format: (.+)")[,2] %>%
    str_split("\\|") %>% unlist()
  
  csq_data <- info(vcf)$CSQ
  rs_ids <- names(rowRanges(vcf))
  
  n_vars <- length(vcf)
  df <- data.frame(matrix(NA, nrow = 1900, ncol = length(csq_fields)))
  colnames(df) <- csq_fields
  
  for (i in seq_len(n_vars)){
    variant = csq_data[i]
    split = str_split(variant@unlistData[1], "\\|")
    df[i,] = split[[1]]
  }
  
  df$variant_id <- rs_ids
  return(df)
}

# Load data
df_alpha   <- extract_csq_df(AM_PP_vcf)
df_cadd    <- extract_csq_df(cadd_vcf)

lines = readLines(sift_vcf)
lines = lines[!grepl("^##SIFT_Threshold", lines)]
writeLines(lines, "cleaned.vcf")
cleaned_sift_vcf <- readVcf("cleaned.vcf", genome = "GRCh38")
csq_header = cleaned_sift_vcf@metadata$header@header@listData$INFO@listData$Description
csq_fields <- str_match(csq_header, "Format: (.+)")[,2] %>%
  str_split("\\|") %>% unlist()
csq_data <- cleaned_sift_vcf@info@listData$SIFTINFO@unlistData
rs_ids <- names(rowRanges(cleaned_sift_vcf))

n_vars <- length(cleaned_sift_vcf)
df_sift <- data.frame(matrix(NA, nrow = 1900, ncol = length(csq_fields)))

colnames(df_sift) <- csq_fields

for (i in seq_len(n_vars)){
  variant = csq_data[i]
  split = str_split(variant, "\\|")
  df_sift[i,] = split[[1]]
}
df_sift$variant_id <- rs_ids

# Merge all datasets
merged <- data.frame(AM_score = df_alpha$am_pathogenicity,
                     CADD_score = df_cadd$CADD_RAW, PP_score = df_alpha$PolyPhen,
                     SIFT_score = df_sift$X9)

rownames(merged) = rs_ids
                     
# Output
write.csv(merged, file = output_csv, row.names = FALSE)