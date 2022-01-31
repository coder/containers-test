#!/usr/bin/env bash
#
# This script generates images.yml.

set -euo pipefail

function append() {
  echo "$@" >>images.yml
}

# Truncate images.yml
echo -n "" >images.yml
append '# Container image build workflow'
append '# This file is automatically generated, see images.yml.sh'
append 'name: images'
append ''
append 'on:'
append '  push:'
append '    branches:'
append '      - main'
append ''
append '  pull_request:'
append '    branches:'
append '      - main'
append ''
append '  schedule:'
append '    # Re-build all images at 2am UTC every Monday (8pm CST/9pm CDT)'
append '    #'
append '    # This ensures we always start with a recent base image, which'
append '    # reduces wasted space due to written-over files in the writable'
append '    # layer, ensures packages are up-to-date (since many of these'
append '    # images install the latest versions of packages available at'
append '    # build time), and allow us to ensure that images continue to'
append '    # be buildable from source (no removed packages).'
append '    #'
append '    # See: https://crontab.guru/#0_2_*_*_1'
append '    - cron: "0 2 * * 1"'
append ''
append '  workflow_dispatch:'
append ''
append 'permissions:'
append '  actions: write # for cancel-workflow-action'
append '  checks: none'
append '  contents: read'
append '  deployments: none'
append '  id-token: write # for workload identity federation'
append '  issues: none'
append '  packages: none'
append '  pull-requests: none'
append '  repository-projects: none'
append '  security-events: none'
append '  statuses: none'
append ''
append 'jobs:'

function write_build() {
  # 1: relative path to image (ubuntu/minimal/focal)
  # 2: relative path to dependent image (may be blank)
  # 3: is default image (add latest tag)
  image_path="$1"
  from_path="${2:-}"
  image_default="${3:-false}"

  # Sanitized names for use in image names
  job_image_name=$(echo "$image_path" | tr "/" "-")
  job_from_name=$(echo "$from_path" | tr "/" "-")

  # Assume the last folder is the default path
  image_name=$(dirname "$image_path")
  tag_name=$(basename "$image_path")
  from_name=$(dirname "$from_path")

  # Create short names (excluding tag name) as short names
  image_name_short=$(echo "$image_name" | tr "/" "-")
  from_name_short=$(echo "$from_name" | tr "/" "-")

  append "  $job_image_name:"
  append "    name: $1"
  if [ -n "$from_path" ]; then
    append '    needs:'
    append "      - $job_from_name"
  fi
  append '    runs-on: ubuntu-20.04'
  append '    steps:'
  append '      - name: Cancel previous runs'
  append "        if: github.event_name == 'pull_request'"
  append '        uses: styfle/cancel-workflow-action@0.9.1'
  append ''
  append '      - name: Checkout'
  append '        uses: actions/checkout@v2'
  append '        with:'
  append '          # unlimited fetch depth is required for files_changed'
  append '          fetch-depth: 0'
  append ''
  append '      - name: Authenticate to Google Cloud'
  append '        uses: google-github-actions/auth@v0'
  append '        with:'
  append '          workload_identity_provider: projects/477254869654/locations/global/workloadIdentityPools/github/providers/github'
  append '          service_account: github@coder-ci.iam.gserviceaccount.com'
  append ''
  append '      - name: Set up Google Cloud SDK'
  append '        uses: google-github-actions/setup-gcloud@v0'
  append ''
  append '      - name: Configure Docker for Google Artifact Registry'
  append '        run: gcloud auth configure-docker us-docker.pkg.dev'
  append ''
  append '      - name: Configure Docker for Docker Hub'
  append "        if: github.event_name != 'pull_request'"
  append '        uses: docker/login-action@v1'
  append '        with:'
  append '          username: ${{ secrets.DOCKERHUB_USERNAME }}'
  append '          password: ${{ secrets.DOCKERHUB_TOKEN }}'
  append ''
  append "      - name: Build coder-${image_name_short}:${tag_name}"
  append '        run: |'
  append '          ./scripts/build_image.sh \'
  append "            --name=coder-${image_name_short} \\"
  append '            --path="${{ github.workspace }}/images/'"$image_path"'" \'
  append '            --tag="'"$tag_name"'" \'
  if [ "$image_default" = true ]; then
    append '            --tag="latest" \'
  fi
  append '            --pull-request="${{ github.event.number }}" \'
  append '            --push=true'
  append ''
}

# Ubuntu 20.04 LTS (Focal Fossa)
write_build "ubuntu/minimal/focal" "" true
write_build "ubuntu/base/focal" "ubuntu/minimal/focal" true

# Ubuntu 22.04 LTS (Jammy Jellyfish)
write_build "ubuntu/minimal/jammy" "" false
write_build "ubuntu/base/jammy" "ubuntu/minimal/jammy" false

# Ubuntu rolling release
write_build "ubuntu/minimal/rolling" "" false
write_build "ubuntu/base/rolling" "ubuntu/minimal/rolling" false

# Debian 11 (bullseye)
write_build "debian/minimal/bullseye" "" true
write_build "debian/base/bullseye" "debian/minimal/bullseye" true

# Debian testing
write_build "debian/minimal/testing" "" false
write_build "debian/base/testing" "debian/minimal/testing" false

# Debian unstable
write_build "debian/minimal/unstable" "" false
write_build "debian/base/unstable" "debian/minimal/unstable" false
