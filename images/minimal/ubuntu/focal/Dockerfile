# Ubuntu 20.04 LTS (Focal Fossa)
ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=library/ubuntu
ARG BASE_TAG=focal

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

SHELL ["/bin/bash", "-c"]

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
      locales

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group

USER coder
