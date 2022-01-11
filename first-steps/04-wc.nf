#!/usr/bin/env nextflow
// https://carpentries-incubator.github.io/workflows-nextflow/01-getting-started-with-nextflow/index.html

nextflow.enable.dsl=2

params.input = "data/yeast/reads/ref1_1.fq.gz"

//  The default workflow
workflow {

    //  Input data is received through channels
    input_ch = Channel.fromPath(params.input)

    /*  The script to execute is called by its process name,
        and input is provided between brackets. */
    NUM_LINES(input_ch)

    /*  Process output is accessed using the `out` channel.
        The channel operator view() is used to print
        process output to the terminal. */
    NUM_LINES.out.view()
}


process NUM_LINES {

    input:
    path read

    output:
    stdout

    script:
    /*  Triple quote syntax """, 
        Triple-single-quoted strings may span multiple lines. 
        The content of the string can cross line boundaries without the need to split the string in several pieces and without concatenation or newline escape characters. 
    */
    """
    printf '${read} '
    gunzip -c ${read} | wc -l
    """
}