# UBI 8
FROM registry.access.redhat.com/ubi8/ubi:latest

SHELL ["/bin/bash", "-c"]

USER 0

RUN dnf install --assumeyes \
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

USER 1000
