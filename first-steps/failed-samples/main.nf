/* 
 *   An assembly pipeline in Nextflow DSL2
 *   -----------------------------------------

 == V4 ==
 This version adds Abricate for AMR detection,
 and the use of a custom script placed in the
 ./bin/ directory.


 */

/* 
 *   Input parameters 
 */


nextflow.enable.dsl = 2
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = "$baseDir/denovo"
params.minreads = 10 // just a very low default

/* 
 *   DSL2 allows to reuse channels
 */
reads = Channel
        .fromFilePairs(params.reads, checkIfExists: true)

        
// prints to the screen and to the log
log.info """
         Denovo Pipeline (version 4)
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()
 


process minreads {
    tag "filter $sample_id"

    input:
    tuple val(sample_id), path(reads) 
    val(min)
    
    output:
    tuple val(sample_id), path("pass/${sample_id}_R*.fastq.gz"), emit: reads optional true 
    
    script:
    """
    TOT=\$(seqfu count ${reads[0]} ${reads[1]} | cut -f 2 )
    mkdir -p pass
    if [[ \$TOT -gt ${min} ]]; then
        mv ${reads[0]} pass/${sample_id}_R1.fastq.gz
        mv ${reads[1]} pass/${sample_id}_R2.fastq.gz
    fi
    
    """
}

process fastp {
    /* 
       fastp process to remove adapters and low quality sequences
    */
    tag "filter $sample_id"

    input:
    tuple val(sample_id), path(reads) 
    
    output:
    tuple val(sample_id), path("${sample_id}_filt_R*.fastq.gz"), emit: reads 
    path("${sample_id}.fastp.json"), emit: json

    /*
       "sed" is a hack to remove _R1 from sample names for MultiQC
        (clean way via config "extra_fn_clean_trim:\n    - '_R1'")
    */
    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} \\
      -o ${sample_id}_filt_R1.fastq.gz -O ${sample_id}_filt_R2.fastq.gz \\
      --detect_adapter_for_pe -w ${task.cpus} -j report.json

    
    sed 's/_R1//g' report.json > ${sample_id}.fastp.json 
    """  
}  

 

process assembly {
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



process prokka {
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

process abricate {
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

process abricate_summary {
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

process quast  {
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

process multiqc {
    publishDir params.outdir, mode:'copy'
       
    input:
    path '*'  
    
    output:
    path 'multiqc_*'
     
    script:
    """
    multiqc --cl_config "prokka_fn_snames: True" . 
    """
} 

workflow {
    minreads( reads, params.minreads )
    fastp( minreads.out.reads )
    assembly( fastp.out.reads )
    abricate( assembly.out )
    prokka( assembly.out )
    
    // QUAST requires all the contigs to be in the same directory
    quast( assembly.out.map{it -> it[1]}.collect() )

    // Prepare the summary of Abricate
    abricate_summary( abricate.out.map{it -> it[1]}.collect() )

    // Collect all the relevant file for MultiQC
    multiqc( fastp.out.json.mix( quast.out , prokka.out, abricate_summary.out.multiqc).collect() )
    
}