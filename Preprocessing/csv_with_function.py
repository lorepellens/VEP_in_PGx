# import modules --------------------------------------------------------
import sys
import os
import inspect
import re
import pandas as pd
from datetime import datetime

os.chdir("/mnt/c/Users/lorep/master_thesis/pharmvar_api")
from client import PharmVarApi

# Help functions --------------------------------------------------------
def filter_NC(variant_list):
    result = []
    for variant in variant_list:
        refseq = re.split("_", variant.hgvs)
        if refseq[0] == "NC":
            result.append(variant)
    return result


# Get all alleles per gene (sub_alleles are excluded) -------------------
pharmvar_api = PharmVarApi()
alleles = pharmvar_api.get_all_alleles(exclude_sub_alleles=True)

count = 0
all_variants = {"hgvs": [], "gene":[], "allele":[], "rs_id": [], "variant_id": [], "impact": [], "ref_col": [], "function": []}

for allele in alleles:
    try:
        variants = pharmvar_api.get_variants_by_allele(allele.pv_id)
        filtered_variants = filter_NC(variants)
        for v in filtered_variants:
            if v.reference_collections == ["GRCh38"]:
                    all_variants["hgvs"].append(v.position)
                    all_variants["gene"].append(allele.gene_symbol)
                    all_variants["allele"].append(allele.allele_name)
                    all_variants["rs_id"].append(v.rs_id)
                    all_variants["variant_id"].append(v.variant_id)
                    all_variants["impact"].append(v.impact)
                    all_variants["ref_col"].append(v.reference_collections)
                    all_variants["function"].append(allele.function)
    except:
        count += 1

dataframe = pd.DataFrame(all_variants)

dataframe.to_csv("variant_list_with_function.csv")


