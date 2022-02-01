process MLST {
    tag { sample_id }
    
    publishDir "$params.outdir/MLST/", 
        mode: 'copy'
    
    input:
    path("*.fa")  
    
    
    output:
    path("mlst.tab"), emit: tab
    path("mlst.json"), emit: json

    script:
    """
    mlst --threads ${task.cpus} --json mlst.json > mlst.tab
    """
}

process MLST_SUMMARY {
    tag { sample_id }
    
    publishDir "$params.outdir/MLST/", 
        mode: 'copy'

    input:
    path("*")

    output:
    path("mlst_mqc.tsv")

    script:
    """    
    mlstToMqc.py -i summary.tsv -o mlst_mqc.tsv
    """
}