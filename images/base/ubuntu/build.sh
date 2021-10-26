#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)
source "$PROJECT_ROOT/lib/trace.sh"

ARCH=${ARCH:-amd64}
IMAGE_REPO="docker.io/library/ubuntu"
IMAGE_TAG=${VERSION:-focal}
IMAGE_REF="${IMAGE_REPO}:${IMAGE_TAG}"
DRY_RUN=${DRY_RUN:-false}

CONTAINER=$(run_trace $DRY_RUN buildah from --pull-never --arch="$ARCH" --cap-drop='ALL' $IMAGE_REF)
if [ $DRY_RUN = true ]; then
  CONTAINER="working-container"
fi

echo "working container: $CONTAINER"

# Update index
run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE,CAP_SETGID,CAP_SETUID,CAP_CHOWN,CAP_FOWNER'" "$CONTAINER" apt-get update --quiet

# Re-enable manual pages. Ubuntu removes these by default to reduce image
# size, which is suitable for most applications, since it's non-interactive.
# For Coder, users are running commands directly in the container, so it's
# useful to have these. Running this command re-installs all packages with
# manpages, so we should run this as early as possible.
echo "y" | run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE,CAP_SETGID,CAP_SETUID,CAP_CHOWN,CAP_FOWNER'" "$CONTAINER" unminimize

# Install base packages
BASE_PACKAGES=(
  apt-listchanges
  apt-transport-https
  apt-utils
  bash
  build-essential
  ca-certificates
  curl
  htop
  language-pack-en
  locales
  man
  python3
  python3-pip
  sudo
  systemd
  systemd-sysv
  unzip
  vim
  wget
)

run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE,CAP_SETGID,CAP_SETUID,CAP_CHOWN,CAP_FOWNER'" "$CONTAINER" apt-get install --no-install-recommends --yes --quiet "${BASE_PACKAGES[@]}"

# Copy files into the container. We do this here because some repositories
# use HTTPS, and hence require apt-transport-https.
run_trace $DRY_RUN buildah copy "$CONTAINER" "files/" "/"

# Refresh the package list since we've added new repositories.
run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE,CAP_SETGID,CAP_SETUID,CAP_CHOWN,CAP_FOWNER'" "$CONTAINER" apt-get update --quiet

# Additional packages from other repositories
THIRD_PARTY_PACKAGES=(
  # Docker (from upstream Docker repository)
  containerd.io
  docker-ce
  docker-ce-cli

  # Git (from git-core PPA)
  git
)

run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE,CAP_SETGID,CAP_SETUID,CAP_CHOWN,CAP_FOWNER'" "$CONTAINER" apt-get install --no-install-recommends --yes --quiet "${THIRD_PARTY_PACKAGES[@]}"

# Delete package cache to avoid consuming space in layer
run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE,CAP_CHOWN,CAP_FOWNER'" "$CONTAINER" apt-get clean
run_trace $DRY_RUN buildah run --cap-add="'CAP_DAC_OVERRIDE'" "$CONTAINER" rm -rf /var/lib/apt/list

run_trace $DRY_RUN buildah commit "$CONTAINER" "base-${IMAGE_TAG}-${ARCH}"

run_trace $DRY_RUN buildah rm "$CONTAINER"
