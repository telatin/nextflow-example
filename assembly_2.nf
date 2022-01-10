/* 
 *   An assembly pipeline in Nextflow DSL2
 *   -----------------------------------------

 This version adds support for Prokka in the MultiQC
 pipeline. This requires a change in the MultiQC step
 to force the use of Prokka filename as sample ID
 (otherwise MultiQC uses the Genus/Species from Prokka) 


 */


/* 
 *   Input parameters 
 */

nextflow.enable.dsl = 2
params.reads = "$baseDir/illumina/*_R{1,2}.fastq.gz"
params.outdir = "$baseDir/denovo"


/* 
 *   DSL2 allows to reuse channels
 */
reads = Channel
        .fromFilePairs(params.reads, checkIfExists: true)

        
// prints to the screen and to the log
log.info """
         RNAquant Pipeline
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()
 


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
    prokka --cpus ${task.cpus} --fast --outdir ${sample_id} --prefix ${sample_id} ${assembly}
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
    path '*' //from quant_ch.mix(fastqc_ch).collect()
    
    output:
    path 'multiqc_*'
     
    script:
    """
    multiqc . 
    """
} 

workflow {
    
    fastp( reads )
    assembly( fastp.out.reads )
    prokka( assembly.out )
    quast( assembly.out.map{it -> it[1]}.collect() )
    multiqc( fastp.out.json.mix( quast.out ).collect() )
}