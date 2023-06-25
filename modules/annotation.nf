
process PROKKA {
    tag { sample_id }
    label 'prokka'
    label 'annotation'
    label 'process_medium'


    input:
    tuple val(sample_id), path(assembly)  
    
    
    output:
    path("${sample_id}")

    script:
    """
    prokka --cpus ${task.cpus} --fast --outdir ${sample_id} --prefix ${sample_id} ${assembly} --
    """
    stub:
    """
    prokka --help
    mkdir ${sample_id}
    """
}

process MLST {
    tag { "running" }
    
    label 'mlst'
    label 'annotation'
    label 'process_low'

    input:
    path("*")  
    
    
    output:
    path("mlst.tab"), emit: tab
    path("mlst.json"), emit: json

    script:
    """
    mlst --threads ${task.cpus} --json mlst.json *.fa > mlst.tab
    """
    stub:
    """
    mlst --help
    touch mlst.tab
    touch mlst.json
    """
}

process MLST_SUMMARY {
    tag { "running" }
    
    label 'mlst'
    label 'annotation'
    label 'process_low'

    input:
    path("summary.tsv")

    output:
    path("mlst_mqc.tsv")

    script:
    """    
    mlstToMqc.py -i summary.tsv -o mlst_mqc.tsv
    """
    stub:
    """
    mlst --help
    touch mlst_mqc.tsv
    """
}

process ABRICATE {
    tag { sample_id }

    label 'annotation'

    input:
    tuple val(sample_id), path(assembly)  
    
    
    output:
    tuple val(sample_id), path("${sample_id}.tab")

    script:
    """
    abricate --threads ${task.cpus}  ${assembly} > ${sample_id}.tab
    """
    stub:
    """
    abricate --help
    touch ${sample_id}.tab
    """
}

process ABRICATE_SUMMARY {
    tag { "running" }
    
    label 'annotation'

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
    stub:
    """
    abricate --help
    touch summary.tsv
    touch abricate_mqc.tsv
    """
}