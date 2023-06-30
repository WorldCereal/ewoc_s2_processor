# =========================================================================
#
#   Copyright 2021 (c) CS Group France. All rights reserved.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# =========================================================================
#
# Authors: Mickaël SAVINAUD (CS Group France)
#
# =========================================================================
FROM ubuntu:20.04
LABEL maintainer="CS GROUP France"
LABEL description="This docker allow to run ewoc_s2 processing chain."

WORKDIR /tmp

ENV LANG=en_US.utf8

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
    python3-pip \
    virtualenv \
    apt-utils file wget \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --upgrade pip \
      && python3 -m pip install --no-cache-dir virtualenv

#------------------------------------------------------------------------
## Install sen2cor
RUN wget --quiet -P /opt http://step.esa.int/thirdparties/sen2cor/2.9.0/Sen2Cor-02.09.00-Linux64.run \
    && chmod +x /opt/Sen2Cor-02.09.00-Linux64.run \
    && /opt/Sen2Cor-02.09.00-Linux64.run \
    && rm /opt/Sen2Cor-02.09.00-Linux64.run
# Copy custom L2A_GIPP.xml to sen2cor home
# This file can be copied to tmp and used as a param
COPY L2A_GIPP.xml /root/sen2cor/2.9/cfg/
RUN mkdir -p /root/sen2cor/2.9/dem/srtm

#------------------------------------------------------------------------
## Install python packages
ARG EWOC_S2_VERSION=0.10.0
LABEL EWOC_S2="${EWOC_S2_VERSION}"
ARG EWOC_DAG_VERSION=0.9.3
LABEL EWOC_DAG="${EWOC_DAG_VERSION}"

# Copy private python packages
COPY ewoc_dag-${EWOC_DAG_VERSION}.tar.gz /tmp
COPY ewoc_s2c-${EWOC_S2_VERSION}.tar.gz /tmp

SHELL ["/bin/bash", "-c"]

ENV EWOC_S2_VENV=/opt/ewoc_s2_venv
RUN python3 -m virtualenv ${EWOC_S2_VENV} \
      && source ${EWOC_S2_VENV}/bin/activate \
      && pip install --no-cache-dir /tmp/ewoc_s2c-${EWOC_S2_VERSION}.tar.gz --find-links=/tmp \
      && pip install --no-cache-dir psycopg2-binary \
      && pip install --no-cache-dir rfc5424-logging-handler

ARG EWOC_S2_DOCKER_VERSION='dev'
ENV EWOC_S2_DOCKER_VERSION=${EWOC_S2_DOCKER_VERSION}
LABEL version=${EWOC_S2_DOCKER_VERSION}

ADD entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
#CMD [ "-h" ]
