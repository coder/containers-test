# CentOS Stream 9
FROM quay.io/centos/centos:stream9

SHELL ["/bin/bash", "-c"]

USER root

RUN dnf install --assumeyes \
      bash \
      ca-certificates \
      curl-minimal \
      git && \
    dnf clean all

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group

USER coder
