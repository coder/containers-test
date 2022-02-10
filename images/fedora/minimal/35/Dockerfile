# Fedora 35
FROM registry.fedoraproject.org/fedora:35

SHELL ["/bin/bash", "-c"]

USER root

RUN dnf install --assumeyes --quiet \
      bash \
      ca-certificates \
      curl \
      git && \
    dnf clean all

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group

USER coder
