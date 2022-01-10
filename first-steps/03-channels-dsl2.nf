/*
DSL2 channels

 Invoke this as:
   nextflow run 03-channels-dsl2.nf --dir 'somedir/*.*' 
*/

nextflow.enable.dsl=2

params.dir = 'data/*.fastq.gz'



// File channels: can only be used once (they are "consumed")
println " -- FILES CHANNELS -- "

read_ch = Channel.fromPath( params.dir, checkIfExists: true )

/*
Reads from a file channel can be used multiple times now 
*/
read_ch.view()
read_ch.view()
