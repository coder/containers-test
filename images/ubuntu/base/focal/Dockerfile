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
    # Install packages from official repository or mirror
    apt-get install --yes --quiet \
      build-essential \
      locales \
      man \
      python3 \
      python3-pip \
      software-properties-common \
      sudo \
      systemd \
      systemd-sysv \
      unzip \
      vim \
      wget && \
    # Re-enable manual pages - Ubuntu strips these by default
    yes | unminimize && \
    # Delete package cache to avoid consuming space in layer
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER coder
