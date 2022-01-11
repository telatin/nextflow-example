FROM condaforge/mambaforge
COPY env.yaml /etc/env.yaml
ENV PATH /opt/imageenv:$PATH
RUN mamba env create -p /opt/imageenv --file /etc/env.yaml
SHELL ["/bin/bash", "--login", "-c"]
ENTRYPOINT ["bash", "-c", "source /opt/conda/bin/activate  /opt/imageenv && \"$@\"", "-s"]
