ARG BASE_CONTAINER=jupyter/minimal-notebook:399cbb986c6b
FROM $BASE_CONTAINER

LABEL maintainer="Eric Charles <eric@datalayer.io>"

USER root

# Install all OS dependencies for fully functional notebook server.
RUN apt-get update && apt-get install -yq --no-install-recommends \
  build-essential \
  git \
  nano \
  pkg-config \
  libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg8-dev libgif-dev \
  && rm -rf /var/lib/apt/lists/*

RUN conda install -y yarn=1.22.5 nodejs=14.5.0

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
# RUN cd && \
#   git clone https://github.com/jupyterlab/jupyterlab.git --branch v3.0.0rc13 --depth 1 && \
#   cd jupyterlab && \
#   pip install -e .

# Install JupyterLab
RUN pip install --pre jupyterlab==3.0.0rc13

# NbDime https://github.com/jupyter/nbdime/pull/551
RUN cd && \
  git clone https://github.com/ajbozarth/nbdime.git --branch lab3 --depth 1
RUN cd nbdime && \
  yarn && \
  yarn build && \
  pip install -e . && \
  jupyter serverextension enable --py nbdime
#   jupyter labextension link . --no-build

# RUN jupyter labextension install @datalayer-jupyter/jupyterlab-nbdime@3.0.0 --no-build

# Git https://github.com/jupyterlab/jupyterlab-git/pull/818
RUN cd && \
  git clone https://github.com/datalayer-contrib/jupyterlab-git.git --branch lab3 --depth 6 && \
  cd jupyterlab-git && \
  yarn && \
  yarn build && \
  pip install -e . && \
  jupyter serverextension enable --py jupyterlab_git && \
  jupyter labextension link . --no-build

# RUN pip install jupyterlab-git
# RUN jupyter labextension install @datalayer-jupyter/jupyterlab-git@0.30.0 --no-build

# Voila https://github.com/voila-dashboards/voila/pull/732
RUN cd && \
  git clone https://github.com/jtpio/voila.git --branch preview-lab3 --depth 1
RUN pip install voila && \
  jupyter serverextension enable voila --sys-prefix
RUN cd voila/packages/jupyterlab-voila && \
  yarn && \
  yarn build && \
  jupyter labextension link . --no-build

# JupyterLab Extension Example.
RUN cd && \
  git clone https://github.com/jupyterlab/jupyterlab-extension-examples.git --branch 3.0 --depth 1 && \
  cd jupyterlab-extension-examples/advanced/server-extension && \
  pip install -e . && \
  jupyter serverextension enable --py jlab_ext_example && \
  jlpm && \
  jlpm build && \
  jupyter labextension link . --no-build

# RUN jupyter lab build

RUN jupyter lab build
RUN jupyter labextension list
RUN pip list | grep jupyterlab

# RUN pip list
# Note the subtle difference...
# RUN jupyter server extension list
# RUN jupyter serverextension list
# RUN jupyter labextension list

# RUN cd && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

USER $NB_UID
