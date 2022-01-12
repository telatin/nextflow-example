process ABRICATE {
    tag { sample_id }
    
    publishDir "$params.outdir/abricate/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), path(assembly)  
    
    
    output:
    tuple val(sample_id), path("${sample_id}.tab")

    script:
    """
    abricate --threads ${task.cpus}  ${assembly} > ${sample_id}.tab
    """
}

process ABRICATE_SUMMARY {
    tag { sample_id }
    
    publishDir "$params.outdir/abricate/", 
        mode: 'copy'

    input:
    path("*")

    output:
    path("summary.tsv")
    path("abricate_mqc.tsv"), emit: multiqc

    script:
    """
    abricate --summary *.tab > summary.tsv
    abricateToMqc.py -i summary.tsv -o abricate_mqc.tsv
    """
}