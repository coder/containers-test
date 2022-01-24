#!/usr/bin/env bash

set -euo pipefail

# Check if files have changed from the default branch (main)
#
# Example:
#   files_changed ./ci/files_changed.sh product/coder/ .github/workflows
function files_changed() {
  # Compare the default branch
  changes=$(git diff --name-only "origin/main...HEAD" -- "$@")
  number=$(echo "$changes" | wc --lines)
  # If the number of changes is nonzero, return success (0)
  if [ "$number" != "0" ]; then
    return 0
  fi

  return 1
}
