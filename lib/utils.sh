#!/usr/bin/env bash

set -euo pipefail

source "${BASH_SOURCE%/*}/indent.sh"
source "${BASH_SOURCE%/*}/trace.sh"

# Check if dependencies are available.
#
# If any dependencies are missing, an error message will be printed to
# stderr and the program will exit, running traps on EXIT beforehand.
#
# Example:
#   check_dependencies git bash node
function check_dependencies() {
  local missing=false
  for command in "$@"; do
    if ! command -v "$command" &> /dev/null; then
      echo "$0: script requires '$command', but it is not in your PATH" >&2
      missing=true
    fi
  done

  if [ $missing = true ]; then
    exit 1
  fi
}

# Emit a message to stderr and exit.
#
# This prints the arguments to stderr before exiting.
function error() {
  echo "$@" >&2
  exit 1
}
