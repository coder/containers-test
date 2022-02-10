# Arch Linux base
FROM docker.io/archlinux/archlinux:base-devel

SHELL ["/bin/bash", "-c"]

USER root

RUN pacman --noconfirm -Syyuu \
      base \
      base-devel \
      bash \
      ca-certificates \
      curl && \
    # Delete package cache to avoid consuming space in layer
    pacman --noconfirm -Scc

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group

USER coder
