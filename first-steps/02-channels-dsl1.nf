/*
DSL1 channels

 Invoke this as:
   nextflow run 02-channels-dsl1.nf --dir 'somedir/*.*' 
*/

params.dir = 'data/*.fastq.gz'

println " -- VALUE CHANNELS -- "
// Value channels: can be used multiple times
ch1 = Channel.value( 'GRCh38' )
ch2 = Channel.value( ['chr1', 'chr2', 'chr3', 'chr4', 'chr5'] )
ch3 = Channel.value( ['chr1' : 248956422, 'chr2' : 242193529, 'chr3' : 198295559] )

// The .view() method can be used to create a view of the channel
println " * [1] Reference: "
ch1.view()
println " * [2] Reference: "
ch1.view()
println " * Chromosomes: "
ch2.view()
println " * Chromosomes and lengths: "
ch3.view()


// File channels: can only be used once (they are "consumed")
println " -- FILES CHANNELS -- "

read_ch = Channel.fromPath( params.dir, checkIfExists: true )
println " [1] Reads: "
read_ch.view()

// try printing again
println " [2] Reads: "
read_ch.view()
