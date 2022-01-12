/*
DSL2 channels
*/

nextflow.enable.dsl=2

// Its important to have the correct pattern here (can be tested with "ls")
params.dir = 'data/*_R{1,2}.fastq.gz'

rintln " -- PAIRED-END READS CHANNELS -- "

read_ch = Channel.fromFilePairs( params.dir, checkIfExists: true )

read_ch.view()

