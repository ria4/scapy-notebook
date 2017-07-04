FROM jupyter/minimal-notebook

MAINTAINER Max Tury "maxence.tury@ssi.gouv.fr"

# Conda needs bash instead of dash
USER root
RUN ln -snf /bin/bash /bin/sh

# Enable Python 2 for the notebook
USER $NB_USER
RUN conda create --quiet --yes -n py27 python=2.7 ipykernel 
RUN source activate py27 && \
    conda install notebook ipykernel && \
    ipython kernel install --user

# Install scapy-dev with dependencies
#RUN git clone https://github.com/pyca/cryptography
RUN git clone -b aead-ccm https://github.com/reaperhulk/cryptography
RUN git clone -b sslv2 https://github.com/mtury/scapy
USER root
RUN apt-get update
RUN apt-get install -yq libssl-dev libffi-dev
RUN source activate py27 && \
    cd cryptography && python setup.py -q install && cd ..
#RUN source activate py27 && \
#    easy_install -q pip && \
#    pip install -q cryptography==1.7.2
RUN source activate py27 && \
    cd scapy && python setup.py -q install && cd ..

# We want to trust the notebooks but there is a bug with Docker ownerships...
COPY notebook1_x509.ipynb notebook2_tls_protected.ipynb notebook3_tls_compromised.ipynb ./
RUN chown jovyan:users notebook1_x509.ipynb notebook2_tls_protected.ipynb notebook3_tls_compromised.ipynb
USER $NB_USER
RUN source activate py27 && \
    ipython trust notebook1_x509.ipynb notebook2_tls_protected.ipynb notebook3_tls_compromised.ipynb
ADD raw_data raw_data/
