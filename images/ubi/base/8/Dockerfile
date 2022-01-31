# UBI 8
ARG BASE_REGISTRY=docker.io/jawnsy
ARG BASE_IMAGE=coder-ubi-minimal
ARG BASE_TAG=8

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

SHELL ["/bin/bash", "-c"]

USER root

# Copy configuration files to appropriate locations
COPY files /

RUN dnf install --assumeyes \
      containerd.io \
      docker-ce \
      docker-ce-cli && \
    dnf clean all

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

# install Homebrew, must be as a non-root user
ENV PATH /home/linuxbrew/.linuxbrew/bin:${PATH}
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
