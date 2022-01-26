# Ubuntu 20.04 LTS (Focal Fossa)
ARG BASE_REGISTRY=docker.io/library
ARG BASE_IMAGE=ubuntu
ARG BASE_TAG=focal

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

SHELL ["/bin/bash", "-c"]

USER root

# Copy configuration files to appropriate locations
COPY files /

# Install packages from apt repositories
ARG DEBIAN_FRONTEND="noninteractive"
# Ignore other repositories here, as some require HTTPS
RUN apt-get update --quiet --option Dir::Etc::SourceParts="" && \
    # Install packages from official repository or mirror
    apt-get install --yes --quiet --option Dir::Etc::SourceParts="" \
      apt-transport-https \
      bash \
      ca-certificates \
      curl \
      locales && \
    # Delete package cache to avoid consuming space in layer
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group

USER coder
