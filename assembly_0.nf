/* 
 *   An assembly pipeline in Nextflow DSL2
 *   -----------------------------------------

 == V0  ==
 Just populating the input channel and showing its content

 */
 
 /* 
 *   Input parameters 
 */

nextflow.enable.dsl = 2
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = "$baseDir/denovo"
params.collect = false

/* 
 *   DSL2 allows to reuse channels
 */
reads = Channel
        .fromFilePairs(params.reads, checkIfExists: true)

        
// prints to the screen and to the log
log.info """
         Denovo Pipeline (version 1)
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         collect:     : ${params.collect}
         """
         .stripIndent()
 
if (params.collect == true)
  reads.map{it -> it[1]}.collect().view()
else
  reads.view()

  