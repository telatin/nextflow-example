/* 
 *   An assembly pipeline in Nextflow DSL2
 *   -----------------------------------------

 == V6 ==
 Added MLST support
 and optional assembler (Unicycler)

 */

/* 
 *   Input parameters 
 */
nextflow.enable.dsl = 2
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = "$baseDir/denovo"
params.unicycler = false
/*
  Import processes from external files
  It is common to name processes with UPPERCASE strings, to make
  the program more readable (this is of course not mandatory)
*/
include { FASTP; MULTIQC } from './modules/qc'
include { SHOVILL; UNICYCLER; PROKKA; QUAST } from './modules/assembly'
include { ABRICATE; ABRICATE_SUMMARY } from './modules/amr'
include { MLST; MLST_SUMMARY } from './modules/misc'

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
         unicycler    : ${params.unicycler}
         """
         .stripIndent()





workflow {
    
    FASTP( reads )
    if (params.unicycler) {
      CONTIGS = UNICYCLER( FASTP.out.reads )
    } else {
      CONTIGS = SHOVILL( FASTP.out.reads  )
    }
    
    ABRICATE( CONTIGS )
    PROKKA( CONTIGS )
    
    // QUAST requires all the contigs to be in the same directory
    QUAST( CONTIGS.map{it -> it[1]}.collect() )
    MLST(  CONTIGS.map{it -> it[1]}.collect() )

    // Prepare the summaries
    ABRICATE_SUMMARY( ABRICATE.out.map{it -> it[1]}.collect() )
    MLST_SUMMARY( MLST.out.tab )

    // Collect all the relevant file for MultiQC
    MULTIQC( FASTP.out.json.mix( QUAST.out , PROKKA.out, MLST_SUMMARY.out, ABRICATE_SUMMARY.out.multiqc).collect() ) 
}