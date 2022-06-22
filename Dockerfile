FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /opt

ARG ARTIFACTORY_LOGIN
ARG ARTIFACTORY_ACCESS_TOKEN

RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
        git \
        rsync \
        wget unzip \
        python3.8-dev python3-pip python3.8-venv \
        python-is-python3 \
        patchelf \
        gcc \
        neovim \
        libgl1-mesa-dev \
        libgl1-mesa-glx \
        libglew-dev \
        libosmesa6-dev && \
    pip install --upgrade pip setuptools wheel && \
    apt autoremove --purge && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /etc/legal /etc/motd

# Install mujoco210
RUN mkdir -p ${HOME}/.mujoco \
  && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
  && tar -zxvf mujoco.tar.gz --no-same-owner --directory ${HOME}/.mujoco \
  && rm mujoco.tar.gz \
  && wget https://roboti.us/file/mjkey.txt -O ${HOME}/.mujoco/mjkey.txt
ENV LD_LIBRARY_PATH ${HOME}/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}
# Install mujoco-2.1.1
RUN mkdir -p ${HOME}/.mujoco \
  && wget https://github.com/deepmind/mujoco/releases/download/2.1.1/mujoco-2.1.1-linux-x86_64.tar.gz -O mujoco.tar.gz \
  && tar -zxvf mujoco.tar.gz --no-same-owner --directory ${HOME}/.mujoco \
  && rm mujoco.tar.gz \
  && wget https://roboti.us/file/mjkey.txt -O ${HOME}/.mujoco/mjkey.txt
ENV LD_LIBRARY_PATH ${HOME}/.mujoco/mujoco-2.1.1/bin:${LD_LIBRARY_PATH}

WORKDIR /opt/predict_act
COPY requirements.txt requirements.txt
RUN pip install "absl-py==1.0.0" "pyparsing==3.0.7"
RUN pip install -r requirements.txt
RUN pip install eai_distributed_toolkit --extra-index-url=https://${ARTIFACTORY_LOGIN}:${ARTIFACTORY_ACCESS_TOKEN}@repo.elmt.io/artifactory/api/pypi/all-pypi-release/simple/

RUN chmod a+rw -R /usr/local/lib/python3.8
