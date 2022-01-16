# How to stop failed samples

Our processes define their input and output files. What if the process is not able to produce the output file?
In this case the workflow would fail, as the _expected_ output file is not found.

If a process might not be able to produce the output file for a good reason, then we can specify that the 
output is, in fact, optional:

```groovy

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
```

If we run this workflow (from the root directory) as:

```bash
nextflow run first-steps/failed-samples/assembly_4.nf --minreads 40000 --reads "data/*_R{1,2}.fastq.gz"
```
only one sample would _survive_ the initial filter, but the pipeline would continue happily with the
`fastp` process:

```text
executor >  local (5)
[c3/0f32e4] process > minreads (filter T7)           [100%] 3 of 3 ✔
[ab/5af5f4] process > fastp (filter T7)              [100%] 1 of 1 ✔
```