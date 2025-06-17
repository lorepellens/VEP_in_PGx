# import modules --------------------------------------------------------
import sys
import os
import inspect
import re
from datetime import datetime
import pandas as pd
import requests
import csv
import numpy as np

os.chdir("/mnt/c/Users/lorep/master_thesis/pharmvar_api")
from client import PharmVarApi

def get_reference_base(chrom, pos, genome="GRCh38"):
    """
    Fetches the reference base from Ensembl API for a given chromosome and position.
    """
    url = f"https://rest.ensembl.org/sequence/region/human/{chrom}:{pos}..{pos}?coord_system=chromosome;assembly={genome}"
    headers = {"Content-Type": "application/json"}

    # Send the request to Ensembl
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        # The response contains the sequence; let's extract the base
        sequence = response.json().get('seq', None)
        
        if sequence:
            return sequence.upper()  # Return the sequence as uppercase
    else:
        print(f"Error fetching reference base for {chrom}:{pos}")
        return None


def parse_hgvs(hgvs_notation):
    """
    Parses HGVS genomic notation and extracts VCF fields: CHROM, POS, REF, ALT.
    
    Example Input: "NC_000007.13:g.117199646G>A"
    Returns: {'CHROM': '7', 'POS': '117199646', 'REF': 'G', 'ALT': 'A'}
    """

    match = re.match(r"NC_0{4,}(\d+)\.\d+:g\.(\d+)([ACGT])>([ACGT])", hgvs_notation)
    match_del = re.match(r"NC_0{4,}(\d+)\.\d+:g\.(\d+)del([ACGT]+)", hgvs_notation)
    match_ins = re.match(r"NC_0{4,}(\d+)\.\d+:g\.(\d+)_(\d+)ins([ACGT]+)", hgvs_notation)
    if match:
        chrom, pos, ref, alt = match.groups()
        return {"CHROM": chrom, "POS": pos, "REF": ref, "ALT": alt}
    elif match_del:
        chrom, pos, ref = match_del.groups()
        return {"CHROM": chrom, "POS": pos, "REF": ref, "ALT": ""}
    elif match_ins:
        chrom, pos1, pos2, inserted_seq = match_ins.groups()
        pos = pos1
        ref = get_reference_base(chrom, pos)
        return {"CHROM": chrom, "POS": pos, "REF": ref, "ALT": ref + inserted_seq}
    else:
        print(f"Error parsing HGVS: {hgvs_notation}")
        return None

result = {"CHROM": [], "POS": [], "ID": [], "REF": [], "ALT": [], "QUAL": []}

# Parse the HGVS variant
with open("variant_list.csv") as data:

    heading = next(data)
    reader = csv.reader(data)
    
    for variant in reader:
        i = variant[1]
        id = variant[2]
        parse = parse_hgvs(i)
        result["CHROM"].append(int(parse["CHROM"]))
        result["POS"].append(parse["POS"])
        result["ID"].append(id)
        result["REF"].append(parse["REF"])
        result["ALT"].append(parse["ALT"])

data = pd.DataFrame.from_dict(result)
sorted_data = data.sort_values(by=['CHROM', 'POS']) 
chrom = sorted_data["CHROM"].values

pos = np.array(sorted_data["POS"])
id = np.array(sorted_data["ID"])
ref = np.array(sorted_data["REF"])
alt = np.array(sorted_data["ALT"])

result = {"CHROM": chrom, "POS": pos, "ID": id, "REF": ref, "ALT": alt}

# Write the VCF file
with open("variants.vcf", "w") as vcf_file:
    # Write the header
    vcf_file.write("##fileformat=VCFv4.2\n")
    vcf_file.write("##source=CustomScript\n")
    vcf_file.write("#CHROM\tPOS\tID\tREF\tALT\n") 

    length_result = len(result["CHROM"])

    for i in range(length_result):
        vcf_file.write(f"{result['CHROM'][i]}\t{result['POS'][i]}\t{result['ID'][i]}\t{result['REF'][i]}\t{result['ALT'][i]}\n")
    
    












