#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)
source "$PROJECT_ROOT/lib/default_branch.sh"
source "$PROJECT_ROOT/lib/files_changed.sh"
source "$PROJECT_ROOT/lib/indent.sh"
source "$PROJECT_ROOT/lib/trace.sh"

DRY_RUN=false

function usage() {
  echo "Usage: $(basename "$0") [options]"
  echo
  echo "This script builds and runs the latest $IMAGE_NAME image, useful"
  echo "for testing changes to the image."
  echo
  echo "Options:"
  echo " -h, --help                  Show this help text and exit"
  echo " --dry-run=false             Show commands that would run, but do not"
  echo "                             run them (optional, default false)"
  exit 1
}

if ! options=$(getopt \
                --name="$(basename "$0")" \
                --longoptions=" \
                  help, \
                  dry-run::, \
                  hostname:, \
                  shared-docker::" \
                --options="h" \
                -- "$@"); then
  usage
fi

eval set -- "$options"
while true; do
  case "${1:-}" in
  --dry-run)
    shift
    if [ -z "$1" ] || [ "$1" == "true" ]; then
      DRY_RUN=true
    else
      DRY_RUN=false
    fi
    ;;
  -h|--help)
    usage
    ;;
  --)
    shift
    break
    ;;
  *)
    # Default case, print an error and quit. This code shouldn't be
    # reachable, because getopt should return an error exit code.
    echo "Unknown option: $1"
    usage
    ;;
  esac
  shift
done
