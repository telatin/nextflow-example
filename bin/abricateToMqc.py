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
    # section_name: 'Abricate summary'
    # description: 'Summary of the AMR genes detected by Abricate'
    # pconfig:
    #     namespace: 'Cust Data'
    # headers:
    #     col1:
    #         title: '#AMR genes'
    #         description: 'Number of sequences'"""

    # Remove indentation from header
    mqc = mqc.replace('    #', '#') + '\n'
    header = "Sample"
    for i, c in enumerate(cols):
        mqc += f"#     col{i+2}: \n"
        mqc += f"#         title: '{c}'\n"
        mqc += f"#         description: 'Coverage of the gene {c}'\n"
        mqc +=  "#         format: '{:,.0f}'\n"
        header += f"\tcol{i+2}"
    mqc += header
    
    return mqc.strip()


if __name__ == "__main__":
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("-i", "--input", required=True, help="Abricate summary file")
    arguments.add_argument("-o", "--output", help="MultiQC output file [default: %(default)s", default="abricate_mqc.txt")
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
            if c == 1:
                columns = fields[1:]
                print(prepareHeader(columns), file=multiqcFile)
                continue
            
            sampleid = fields[0].replace(".tab", "")
            print("\t".join([sampleid] + fields[1:]), file=multiqcFile)
            


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