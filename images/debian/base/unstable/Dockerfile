# Debian unstable (sid)
ARG BASE_REGISTRY=docker.io/jawnsy
ARG BASE_IMAGE=coder-debian-minimal
ARG BASE_TAG=unstable

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

SHELL ["/bin/bash", "-c"]

USER root

# Copy configuration files to appropriate locations
COPY files /

# Install packages from apt repositories
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update --quiet && \
    # Install packages from official repository or mirror
    apt-get install --yes --quiet \
      build-essential \
      git \
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
    # Docker (from upstream Docker repository)
    apt-get install --yes --quiet \
      containerd.io \
      docker-ce \
      docker-ce-cli && \
    # Delete package cache to avoid consuming space in layer
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN usermod --groups docker coder

# Add docker-compose
RUN curl --location "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-linux-x86_64" \
      --silent --output /usr/local/bin/docker-compose-v1 && \
    chmod +x /usr/local/bin/docker-compose-v1 && \
    # Compose V2 as docker plugin
    mkdir --parents /usr/local/lib/docker/cli-plugins && \
    curl --location "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
      --silent --output /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose && \
    # compose-switch for handling compose v1/v2 compatibility
    curl --location "https://github.com/docker/compose-switch/releases/latest/download/docker-compose-linux-amd64" \
      --silent --output /usr/local/bin/docker-compose-switch && \
    chmod +x /usr/local/bin/docker-compose-switch && \
    update-alternatives --install /usr/local/bin/docker-compose docker-compose /usr/local/bin/docker-compose-v1 1 && \
    update-alternatives --install /usr/local/bin/docker-compose docker-compose /usr/local/bin/docker-compose-switch 99

USER coder
