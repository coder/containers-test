# Fedora rawhide
FROM registry.fedoraproject.org/fedora:rawhide

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
