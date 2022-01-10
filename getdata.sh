#!/usr/bin/env bash

if [[ ! -e "imgs" ]]; then
    echo "This script should be executed from the repository root."
    exit 1
fi
set -euxo pipefail
mkdir -p data

curl --silent -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR128/099/SRR12825099/SRR12825099_1.fastq.gz -o data/SRR12825099_Shigella_R1.fastq.gz
curl --silent -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR128/099/SRR12825099/SRR12825099_2.fastq.gz -o data/SRR12825099_Shigella_R2.fastq.gz
curl --silent -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/042/SRR12971242/SRR12971242_1.fastq.gz -o data/SRR12971242_Escherichia_R1.fastq.gz
curl --silent -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/042/SRR12971242/SRR12971242_2.fastq.gz -o data/SRR12971242_Escherichia_R2.fastq.gz
curl --silent -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/041/SRR12971241/SRR12971241_1.fastq.gz -o data/SRR12971241_Escherichia_R1.fastq.gz
curl --silent -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR129/041/SRR12971241/SRR12971241_2.fastq.gz -o data/SRR12971241_Escherichia_R2.fastq.gz