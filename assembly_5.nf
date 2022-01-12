/* 
 *   An assembly pipeline in Nextflow DSL2
 *   -----------------------------------------

 == V5 ==
 Modularized version 

 */

/* 
 *   Input parameters 
 */
nextflow.enable.dsl = 2
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = "$baseDir/denovo"

/*
  Import processes from external files
  It is common to name processes with UPPERCASE strings, to make
  the program more readable (this is of course not mandatory)
*/
include { FASTP; MULTIQC } from './modules/qc'
include { SHOVILL; PROKKA; QUAST } from './modules/assembly'
include { ABRICATE; ABRICATE_SUMMARY } from './modules/amr'

/* 
 *   DSL2 allows to reuse channels
 */
reads = Channel
        .fromFilePairs(params.reads, checkIfExists: true)

        
// prints to the screen and to the log
log.info """
         Denovo Pipeline (version 5)
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()





workflow {
    
    FASTP( reads )
    SHOVILL( FASTP.out.reads )
    ABRICATE( SHOVILL.out )
    PROKKA( SHOVILL.out )
    
    // QUAST requires all the contigs to be in the same directory
    QUAST( SHOVILL.out.map{it -> it[1]}.collect() )

    // Prepare the summary of Abricate
    ABRICATE_SUMMARY( ABRICATE.out.map{it -> it[1]}.collect() )

    // Collect all the relevant file for MultiQC
    MULTIQC( FASTP.out.json.mix( QUAST.out , PROKKA.out, ABRICATE_SUMMARY.out.multiqc).collect() )
    
}