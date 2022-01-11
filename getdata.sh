#!/usr/bin/env bash
OK=' ✅ ' 
if [[ ! -e "imgs" ]]; then
    echo "This script should be executed from the repository root."
    exit 1
fi

set -euo pipefail
mkdir -p data

if [[ ! -e "data/SRR12825099_R1.fastq.gz" ]];
then
    echo "[1] Downloading small dataset"
    curl --silent -L -o  smalldataset.tar.gz https://github.com/telatin/nextflow-example/releases/download/v0.1.0/smalldataset.tar.gz
    tar xfz smalldataset.tar.gz
    echo "    DONE $OK"
else
    echo "Warning: Small dataset already downloaded. $OK"
fi

if [[ ! -z ${1+x} ]] && [[ $1 == "full" ]];
then
    if [[ ! -e "data/SRR12971241_Escherichia_R2.fastq.gz" ]];
    then
        echo "[2] Downloading full dataset"
        curl --silent -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR128/099/SRR12825099/SRR12825099_1.fastq.gz" -o "data/SRR12825099_Shigella_R1.fastq.gz"
        curl --silent -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR128/099/SRR12825099/SRR12825099_2.fastq.gz" -o "data/SRR12825099_Shigella_R2.fastq.gz"
        curl --silent -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/042/SRR12971242/SRR12971242_1.fastq.gz" -o "data/SRR12971242_Escherichia_R1.fastq.gz"
        curl --silent -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/042/SRR12971242/SRR12971242_2.fastq.gz" -o "data/SRR12971242_Escherichia_R2.fastq.gz"
        curl --silent -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/041/SRR12971241/SRR12971241_1.fastq.gz" -o "data/SRR12971241_Escherichia_R1.fastq.gz"
        curl --silent -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/041/SRR12971241/SRR12971241_2.fastq.gz" -o "data/SRR12971241_Escherichia_R2.fastq.gz"
        echo "    DONE $OK"
    else
        echo "Warning: Bacterial genomes dataset already downloaded. $OK"
    fi
else
    echo "Note: Specify 'full' as argument to download three genomes"
fi