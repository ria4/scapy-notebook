FROM jupyter/minimal-notebook

USER $NB_USER

RUN conda create --quiet --yes -n py27 python=2.7 ipykernel 

RUN /bin/bash -c "source activate py27 && conda install notebook ipykernel && ipython kernel install --user"
