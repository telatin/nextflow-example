process SHOVILL {
    /* 
       assembly step. here we used a conditional logic to choose the assembler
    */
    tag { sample_id }
    label 'shovill'
    label 'assembly'
    label 'process_medium'

    input:
    tuple val(sample_id), path(reads)  
    
    
    output:
    tuple val(sample_id), path("${sample_id}.fa")

    script:
    """
    shovill --R1 ${reads[0]} --R2 ${reads[1]} --outdir shovill --cpus ${task.cpus}
    mv shovill/contigs.fa ${sample_id}.fa
    """
    stub:
    """
    touch ${sample_id}.fa
    """
}


process UNICYCLER {
 
    tag { sample_id }
    label 'unicycler'
    label 'assembly'
    label 'process_medium'

    input:
    tuple val(sample_id), path(reads)  
    
    
    output:
    tuple val(sample_id), path("${sample_id}.fa")

    script:
    """
    unicycler -1 ${reads[0]} -2 ${reads[1]} -o unicycler -t ${task.cpus} --keep 0 --min_fasta_length 200
    mv unicycler/assembly.fasta ${sample_id}.fa
    """
}
