# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

ARG BASE_CONTAINER=jupyter/minimal-notebook:b90cce83f37b

FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install all OS dependencies for fully functional notebook server.
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
# TODO Latest commmits fail the server to start, so we use for now 3b09860 commit
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

# TODO Fix the installation of nbclassic.json
# 1. With pip install -e ., nbclassic.json is put in /opt/conda/jupyter-config/jupyter/jupyter_server_config.d/nbclassic.json 
# which is not where it should be (afaik it should be in /opt/conda/etc/jupyter/jupyter_server_config.d/)
# 2. With pip install ., nbclassic python package is not found by jupyterlab.
RUN mkdir -p /opt/conda/etc/jupyter/jupyter_server_config.d/
RUN cd && \
  cp nbclassic/jupyter-config/jupyter/jupyter_server_config.d/nbclassic.json /opt/conda/etc/jupyter/jupyter_server_config.d/

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
   jupyter serverextension enable --py jlab_ext_example && \
   jlpm && \
   jlpm build && \
   jupyter labextension link .

# No need to build JupyterLab (jupyter labextension link has done that for us...).
# RUN jupyter lab build

# RUN pip list
# Note the subtle difference...
# RUN jupyter server extension list
# RUN jupyter serverextension list
# RUN jupyter labextension list

# RUN cd && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

USER $NB_UID
