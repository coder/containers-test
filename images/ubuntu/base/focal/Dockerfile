# Ubuntu 20.04 LTS (Focal Fossa)
ARG BASE_REGISTRY=docker.io/jawnsy
ARG BASE_IMAGE=coder-ubuntu-minimal
ARG BASE_TAG=focal

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

SHELL ["/bin/bash", "-c"]

USER root

# Copy configuration files to appropriate locations
COPY files /

# Install packages from apt repositories
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update --quiet && \
    # Re-enable manual pages - Ubuntu strips these by default
    yes | unminimize && \
    # Install packages from official repository or mirror
    apt-get install --yes --quiet \
      build-essential \
      htop \
      man \
      openssh-server \
      python3 \
      python3-pip \
      software-properties-common \
      sudo \
      systemd \
      systemd-sysv \
      unzip \
      vim \
      wget && \
    # Git (from Ubuntu PPA)
    apt-get install --yes --quiet \
      git && \
    # Docker (from upstream Docker repository)
    apt-get install --yes --quiet \
      containerd.io \
      docker-ce \
      docker-ce-cli && \
    # Delete package cache to avoid consuming space in layer
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure systemd services for CVMs
RUN systemctl enable \
      docker \
      ssh

# Add docker-compose
RUN curl --location "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
      --output /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

USER coder
