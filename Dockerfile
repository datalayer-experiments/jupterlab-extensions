# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

ARG BASE_CONTAINER=jupyter/minimal-notebook:399cbb986c6b

FROM $BASE_CONTAINER

LABEL maintainer="Eric Charles"

USER root

# Install all OS dependencies for fully functional notebook server.
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    nano \
    pkg-config \
    libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg8-dev libgif-dev \
    && rm -rf /var/lib/apt/lists/*

# Remove JupyterLab.
RUN conda remove --quiet --yes \
    'jupyterlab' && \
    conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Clone and Install JupyterLab.
RUN cd && \
    git clone https://github.com/jupyterlab/jupyterlab.git --branch master --depth 1 && \
    cd jupyterlab && \
    pip install -e .

# Install JupyterLab Server Example extension.
RUN cd && \
   git clone https://github.com/jupyterlab/jupyterlab-extension-examples.git --branch 3.0 --depth 1 && \
   cd jupyterlab-extension-examples/advanced/server-extension && \
   pip install -e . && \
   jupyter serverextension enable --py jlab_ext_example && \
   jlpm && \
   jlpm build && \
   jupyter labextension link .

# https://github.com/voila-dashboards/voila/pull/732
RUN cd && \
   git clone https://github.com/jtpio/voila.git --branch preview-lab3 --depth 1 && \
   cd voila/packages/jupyterlab-voila && \
   jlpm && \
   jlpm build && \
   jupyter labextension link .

# https://github.com/jupyter/nbdime/pull/551
RUN cd && \
   git clone https://github.com/ajbozarth/nbdime.git --branch lab3 --depth 1 && \
   cd voila/packages/jupyterlab-voila && \
   jlpm && \
   jlpm build && \
   jupyter labextension link .

# https://github.com/jupyterlab/jupyterlab-git/pull/818
RUN cd && \
   git clone https://github.com/ajbozarth/jupyterlab-git.git --branch lab3 --depth 1 && \
   cd voila/packages/jupyterlab-voila && \
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
