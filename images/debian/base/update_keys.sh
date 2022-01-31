#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)

curl_flags=(
  --silent
  --show-error
  --location
)

gpg_flags=(
  --dearmor
  --yes
)

tags=(
  bullseye
  testing
  unstable
)

for tag in "${tags[@]}"; do
  pushd "$PROJECT_ROOT/images/debian/base/$tag/files/usr/local/share/keyrings"
    # Upstream Docker signing key
    curl "${curl_flags[@]}" "https://download.docker.com/linux/debian/gpg" | \
      gpg "${gpg_flags[@]}" --output="docker.gpg"
  popd
done
