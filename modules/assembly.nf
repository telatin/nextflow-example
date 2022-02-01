
process QUAST  {
    tag "quast"
    
    publishDir "$params.outdir/", 
        mode: 'copy'
    
    input:
    path("*")  
    
    
    output:
    path("quast")

    script:
    """
    quast --threads ${task.cpus} --output-dir quast *.fa
    """
}

process SHOVILL {
    /* 
       assembly step. here we used a conditional logic to choose the assembler
    */
    tag { sample_id }
    
    publishDir "$params.outdir/assemblies/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), path(reads)  
    
    
    output:
    tuple val(sample_id), path("${sample_id}.fa")

    script:
    """
    shovill --R1 ${reads[0]} --R2 ${reads[1]} --outdir shovill --cpus ${task.cpus}
    mv shovill/contigs.fa ${sample_id}.fa
    """
}


process UNICYCLER {
 
    tag { sample_id }
    
    publishDir "$params.outdir/assemblies/", 
        mode: 'copy'
    
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



process PROKKA {
    tag { sample_id }
    
    publishDir "$params.outdir/annotation/", 
        mode: 'copy'
    
    input:
    tuple val(sample_id), path(assembly)  
    
    
    output:
    //tuple val(sample_id), path("${sample_id}/report.{pdf,html}")
    path("${sample_id}")

    script:
    """
    prokka --cpus ${task.cpus} --fast --outdir ${sample_id} --prefix ${sample_id} ${assembly} --
    """
}