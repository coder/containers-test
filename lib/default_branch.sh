#!/usr/bin/env bash

set -euo pipefail

# Return true if the current branch is the default branch
function is_branch() {
  branch=$(git branch --show-current)
  if [ "$branch" == "$1" ]; then
    return 0
  fi

  return 1
}
