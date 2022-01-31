# UBI 8
ARG BASE_REGISTRY=docker.io/jawnsy
ARG BASE_IMAGE=coder-ubi-minimal
ARG BASE_TAG=8

SHELL ["/bin/bash", "-c"]

USER root

# Copy configuration files to appropriate locations
COPY files /

RUN dnf install --assumeyes \
      containerd.io \
      docker-ce \
      docker-ce-cli && \
    dnf clean all

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group

USER coder
