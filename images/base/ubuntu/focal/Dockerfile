FROM ubuntu:focal

SHELL ["/bin/bash", "-c"]

# Copy configuration files to appropriate locations
COPY files /

# Install baseline packages
ARG DEBIAN_FRONTEND="noninteractive"
# Ignore other repositories here, as some require HTTPS
RUN apt-get update --quiet --option Dir::Etc::SourceParts="" && \
    # Install packages from official repository or mirror
    apt-get install --no-install-recommends --yes --quiet --option Dir::Etc::SourceParts="" \
      apt-listchanges \
      apt-transport-https \
      apt-utils \
      bash \
      build-essential \
      ca-certificates \
      curl \
      htop \
      language-pack-en \
      locales \
      man \
      python3 \
      python3-pip \
      sudo \
      systemd \
      systemd-sysv \
      unzip \
      vim \
      wget && \
    # Re-enable manual pages - Ubuntu strips these by default
    yes | unminimize && \
    # Install packages from third-party repositories
    apt-get update --quiet && \
    # Docker (from upstream Docker repository)
    apt-get install --no-install-recommends --yes --quiet \
      containerd.io \
      docker-ce \
      docker-ce-cli && \
    # Git
    apt-get install --no-install-recommends --yes --quiet \
      git && \
    # Delete package cache to avoid consuming space in layer
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enables Docker starting with systemd
RUN systemctl enable docker

# Add docker-compose
ARG DOCKER_COMPOSE_VERSION=1.29.2
RUN curl --silent --show-error --location --output /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname --kernel-name)-$(uname --machine)" && \
      chmod a=rx /usr/local/bin/docker-compose

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --groups=docker \
      --uid=1000 \
      --user-group

USER 1000
