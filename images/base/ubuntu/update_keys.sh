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
  focal
)

for tag in "${tags[@]}"; then
  pushd "$PROJECT_ROOT/images/minimal/ubuntu/$tag/files/usr/share/keyrings"
    # Upstream Docker signing key
    curl "${curl_flags[@]}" "https://download.docker.com/linux/ubuntu/gpg" | \
      gpg "${gpg_flags[@]}" --output="docker.gpg"

    # Git PPA signing key
    curl "${curl_flags[@]}" "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xe1dd270288b4e6030699e45fa1715d88e1df1f24" | \
      gpg "${gpg_flags[@]}" --output="git-core.gpg"
  popd
done
