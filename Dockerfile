# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

ARG BASE_CONTAINER=jupyter/minimal-notebook:b90cce83f37b

FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Remove JupyterLab
RUN conda remove --quiet --yes \
    'jupyterlab' && \
    conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Clone and Install Jupyter Server.
RUN cd && \
    git clone https://github.com/Zsailer/jupyter_server.git --branch extension-loading && \
    cd jupyter_server && \
    git checkout 3b09860 && \
    pip install -e .

# Clone and Install NBClassic.
RUN cd && \
    git clone https://github.com/Zsailer/nbclassic.git --branch master --depth 1 && \
    cd nbclassic && \
    pip install -e .

# Clone and Install JupyterLab Server.
RUN cd && \
    git clone https://github.com/datalayer-contrib/jupyterlab-server.git --branch jupyter_server --depth 1 && \
    cd jupyterlab-server && \
    pip install -e .

# Clone and Install JupyterLab.
RUN cd && \
    git clone https://github.com/datalayer-contrib/jupyterlab.git --branch jupyter_server --depth 1 && \
    cd jupyterlab && \
    pip install -e .

# Install JupyterLab Server Example extension.
RUN cd && \
   git clone https://github.com/datalayer-contrib/jupyterlab-extension-examples.git --branch jupyter_server --depth 1 && \
   cd jupyterlab-extension-examples/advanced/server-extension && \
   pip install -e . && \
   jlpm && \
   jlpm build && \
   jupyter labextension link .

RUN jupyter serverextension enable --py jlab_ext_example

# No need to build JupyterLab (jupyter labextension link has done that for us...).
# RUN jupyter lab build

RUN pip list

# Note the subtle difference...
RUN jupyter server extension list
RUN jupyter serverextension list

RUN jupyter labextension list

# RUN cd && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

USER $NB_UID
