
process FASTP {
    /* 
       fastp process to remove adapters and low quality sequences
    */
    tag "${sample_id}"
    
    label 'fastp'
    label 'qc'
    label 'process_medium'

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
    
    stub:
    """
    fastp -?
    touch ${sample_id}.fastp.json
    touch ${sample_id}_filt_R{1,2}.fastq.gz 
    """
}  

process SUBSAMPLE {
    tag {sample_id}
    
    label 'downsample'
    label 'qc'
    label 'process_medium'
    
    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), path("*.sub.fastq.gz")
    script:
    def args = task.ext.args ?: "-f 25" 
    """
    rasusa $args -s 2023 -i ${reads[0]} -i ${reads[1]} -o ${sample_id}_R1.sub.fastq.gz -o ${sample_id}_R2.sub.fastq.gz
    """
}

process QUAST  {
    tag "quack quack 🦆"
    
    label 'quast'
    label 'qc'
    label 'process_medium'

    input:
    path("*")  
    
    output:
    path("quast")

    script:
    """
    quast --threads ${task.cpus} --output-dir quast *.fa
    """
    stub:
    """
    quast -h
    mkdir quast
    """
}

process MULTIQC {
    tag '🥐'

    label 'multiqc'
    label 'qc'
    label 'process_medium'

    input:
    path '*'  
    
    output:
    path 'multiqc_*'
     
    script:
    """
    multiqc --cl-config "prokka_fn_snames: True" . 
    """
    stub:
    """
    multiqc -h
    touch multiqc_.html
    """
} 