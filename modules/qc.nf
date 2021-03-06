
process FASTP {
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

 

process MULTIQC {
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