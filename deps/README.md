# Dependencies

Any workflow requires a set of dependencies. 
Nextflow gives a range of helper features to manage the
_dependency hell_.

## A simple workflow

To start practicing with Nextflow you can use a simple workflow:

1. Gather the tools you need from bioconda creating an environment
1. Experiment the pipeline with your environment
1. When ready, export your environment as a yaml file 
1. Convert the environment to a container (Docker or Singularity)

In this way you can combine the convenience of a simple prototyping
with the robustness of containers.

## Converting an environment to a Singularity image

A definition file that is based on a YAML file makes it easy to immediately
create an image just changing the YAML file.

Here an example of a definition file that will load a `./env.yaml` file
to be used to create the whole image modeled as a conda environment.

```singularity
Bootstrap: docker
From: centos:centos7.6.1810

%files
    ./env.yaml /etc/env.yaml

%environment
    source /opt/software/conda/bin/activate /opt/software/conda_env


%post
    yum -y install epel-release wget which nano curl zlib-devel
    yum -y groupinstall "Development Tools"

    mkdir -p /opt/software

    cd /opt/software
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    sh ./Miniconda3-latest-Linux-x86_64.sh -p /opt/software/conda -b

    /opt/software/conda/bin/conda config --add channels defaults
    /opt/software/conda/bin/conda config --add channels conda-forge
    /opt/software/conda/bin/conda config --add channels bioconda
    /opt/software/conda/bin/conda install -y -c conda-forge mamba
    ls -l /etc/*.yaml
    /opt/software/conda/bin/mamba env create -p /opt/software/conda_env  --file /etc/env.yaml
    source /opt/software/conda/bin/activate /opt/software/conda_env

    cd /opt/software
```

To build the image (`.simg`) from the definition file (`.def`):
```bash
sudo singularity build denovo.simg denovo.def
```


## Converting an environment to a Docker image

A dockerfile is provided, that can be built with:

```bash
# We can call the image "denovo", tagging it as last version
sudo docker build -t denovo:latest .

# Test any tool like:
sudo docker run --rm denovo:latest abricate -h
```

## A different approach: nf-core modules

DSL2 enabled a modular approach, and the ["nf-core" organization](https://nf-co.re/)
curates a set of [reusable modules](https://github.com/nf-core/modules#readme).

The use of Bioconda packages enables the developers to specify the source of the
tools from the module itself, for example if `bwa` is required:

```nextflow
    conda (params.enable_conda ? "bioconda::bwa=0.7.17" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bwa:0.7.17--hed695b0_7' :
        'quay.io/biocontainers/bwa:0.7.17--hed695b0_7' }"
```