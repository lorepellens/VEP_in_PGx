lib <- "/R/site-library"
if (!dir.exists(lib)) dir.create(lib, recursive = TRUE)
.libPaths(lib)

# Load/install required packages

if (!requireNamespace("e1071", quietly = TRUE)) 
    install.packages("e1071", lib = lib, repos = "https://cloud.r-project.org")
if (!requireNamespace("dplyr", quietly = TRUE)) 
    install.packages("dplyr", lib = lib, repos = "https://cloud.r-project.org")

library(e1071)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file <- args[2]

# Load model
svm_model <- readRDS("svm_model.RDS")

# Read new data
newdata <- read.csv(input_file)
newdata$PP_score = as.numeric(sub(".*\\((.*)\\)", "\\1", newdata$PP_score))

# Normalize
newdata$inverted_SIFT_score = 1 - newdata$SIFT_score # deleterious is low score so take inverse
newdata = newdata %>% mutate(
  AM_scaled = scale(AM_score)[,1],
  CADD_scaled = scale(CADD_score)[,1],
  PolyPhen2_scaled = scale(PP_score)[,1],
  SIFT_scaled = scale(SIFT_score)[,1],
  SIFT_inverted_scaled = scale(inverted_SIFT_score)[,1]
)

newdata = na.omit(newdata)

# Predict using the model
predictions <- predict(svm_model, newdata)
probs_svm = attr(predict(svm_model, newdata, probability = TRUE), "probabilities")
row.names(probs_svm) = newdata$rs_id

# Save predictions along with variants identifiers (assuming a column 'variant_id')
write.csv(probs_svm, "output_ensemble_method.csv",row.names=TRUE)
