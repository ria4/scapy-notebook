FROM jupyter/minimal-notebook

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
RUN source activate py27 && \
    cd scapy && python setup.py -q install && cd ..

# We want to trust the notebooks but there is a bug with Docker ownerships...
ADD notebooks notebooks/
RUN chown -R jovyan:users notebooks
USER $NB_USER
RUN cd notebooks && \
    source activate py27 && \
    ipython trust notebook0_intro.ipynb notebook1_x509.ipynb notebook2_tls_protected.ipynb notebook3_tls_compromised.ipynb notebook4_tls13.ipynb && \
    cd ..
