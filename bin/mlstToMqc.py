#!/usr/bin/env python3
"""
Convert an Abriacate summary file to a MultiQC-ready
file
"""

import os, sys
import argparse

def prepareHeader(cols):
    """
    Prepare the header for the output file
    """
    mqc = """
    # plot_type: 'table'
    # section_name: 'MLST summary'
    # description: 'Summary of the MLST typing'
    # pconfig:
    #     namespace: 'Cust Data'
    # headers:
    #     col1:
    #         title: 'Scheme'
    #         description: 'Number of sequences'
    #     col2:
    #         title: 'ST'
    #         description: 'Isolate Sequence Type'"""

    # Remove indentation from header
    mqc = mqc.replace('    #', '#') + '\n'

    header = "Sample"
    for i, c in enumerate(cols):
        geneName = c.split("(")[0]
        mqc += f"#     col{i+1}: \n"
        mqc += f"#         title: '{geneName}'\n"
        mqc += f"#         description: '{geneName} allele'\n"
        mqc +=  "#         format: '{:,.0f}'\n"
        header += f"\tcol{i+1}"
    mqc += header
    
    return mqc.strip()

def getAllele(s):
    """
    Get the allele from the MLST string
    """
    if "(" in s and ")" in s:
        return s.split("(")[1].split(")")[0]
    else:
        return s

if __name__ == "__main__":
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("-i", "--input", required=True, help="MLST summary file")
    arguments.add_argument("-o", "--output", help="MultiQC output file [default: %(default)s", default="mlst_mqc.txt")
    arguments.add_argument("--stdout", help="Print output to stdout", action="store_true")
    args = arguments.parse_args()

    # Open output file
    if args.stdout:
        multiqcFile = sys.stdout
    else:
        multiqcFile = open(args.output, "w")

    with open(args.input, "r") as fh:
        c = 0
        columns = []
        for line in fh:
            c += 1

            fields = line.strip().split("\t")

            # Basename for fields[0]
             
            if fields[0].endswith(".fa"):
                fields[0] = fields[0][:-3]

            if c == 1:
                columns = fields[1:]
                print(prepareHeader(columns), file=multiqcFile)
                
            
            sampleid = os.path.basename(fields[0])

            # Process all fields with the getAllele function
            n = [getAllele(f) for f in fields]
            print("\t".join([sampleid] + n[1:]), file=multiqcFile)
            


"""
# plot_type: 'table'
# section_name: 'Abricate summary'
# description: 'Summary of the AMR genes detected by Abricate'
# pconfig:
#     namespace: 'Cust Data'
# headers:
#     col1:
#         title: '#Seqs'
#         description: 'Number of sequences'
#         format: '{:,.0f}'
#     col2:
#         title: 'Total bp'
#         description: 'Total size of the dataset'
#     col3:
#         title: 'Avg'
#         description: 'Average sequence length'
#     col4:
#         title: 'N50'
#         description: '50% of the sequences are longer than this size'
#     col5:
#         title: 'N75'
#         description: '75% of the sequences are longer than this size'
#     col6:
#         title: 'N90'
#         description: '90% of the sequences are longer than this size'
#     col7:
#         title: 'Min'
#         description: 'Length of the shortest sequence'
#     col8:
#         title: 'Max'
#         description: 'Length of the longest sequence'
#     col9:
#         title: 'auN'
#         description: 'Area under the Nx curve'
Sample  col1    col2    col3    col4    col5    col6    col7  col8  col9
../assemblies/GCA009944615.fa   1       89214   89214.0 89214   89214   89214   89214.000       89214   89214
../assemblies/SRR12825099.fa    2       6196    3098.0  6110    6110    6110    6026.387        86      6110
../assemblies/SRR12825099_Shigella.fa   643     4586667 7133.2  19056   9856    4836    23323.941       104     80358
../assemblies/SRR12971241_Escherichia.fa        263     5242123 19932.0 94332   43887   19612   104633.459      128     266200
"""