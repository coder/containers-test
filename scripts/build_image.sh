#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)
source "$PROJECT_ROOT/lib/default_branch.sh"
source "$PROJECT_ROOT/lib/files_changed.sh"
source "$PROJECT_ROOT/lib/indent.sh"
source "$PROJECT_ROOT/lib/trace.sh"

CI=${CI:-false}
DRY_RUN=false
IMAGE_NAME=""
IMAGE_PATH=$PWD
IMAGE_PUSH=false
IMAGE_TAGS=()

REGISTRY_PRODUCTION="docker.io/jawnsy"
REGISTRY_DEVELOPMENT="us-docker.pkg.dev/coder-ci/containers"

function usage() {
  echo "Usage: $(basename "$0") [options]"
  echo
  echo "This script builds, tags, and optionally pushes a given image."
  echo ""
  echo "When running in GitHub Actions for push events on the default"
  echo "branch, the script will unconditionally rebuild images."
  echo ""
  echo "When running against pull requests, the script will build"
  echo "images when the source is modified, and otherwise pull the"
  echo "latest version of the image from Docker Hub, and copy it to"
  echo "the Google Cloud Artifact Registry for the pull request."
  echo
  echo "Options:"
  echo " -h, --help                  Show this help text and exit"
  echo " --dry-run=false             Show commands that would run, but do not"
  echo "                             run them (optional, default false)"
  echo " --name=[name]               Name of the image (required)"
  echo " --path=[path]               Path to the Docker context directory"
  echo "                             (optional, defaults to working directory)"
  echo " --pull-request=[number]     The pull request number, if the build is"
  echo "                             running against a pull request"
  echo " --push=$IMAGE_PUSH          Push images to the image registry"
  echo "                             (optional, default $IMAGE_PUSH)"
  echo " --tag=[name]                Image tag to use (required, may be used"
  echo "                             multiple times)"
  exit 1
}

if ! options=$(getopt \
                --name="$(basename "$0")" \
                --longoptions=" \
                    help, \
                    dry-run::, \
                    name:, \
                    path::, \
                    pull-request::, \
                    push::, \
                    tag::" \
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
  --name)
    shift
    IMAGE_NAME=$1
    ;;
  --path)
    shift
    IMAGE_PATH=$1
    ;;
  --pull-request)
    shift
    PULL_REQUEST=$1
    ;;
  --push)
    shift
    if [ -z "$1" ] || [ "$1" == "true" ]; then
      IMAGE_PUSH=true
    else
      IMAGE_PUSH=false
    fi
    ;;
  --tag)
    shift
    IMAGE_TAGS+=("$1")
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

if [ -z "$CI" ]; then
  echo "This script is designed to run only in CI" >&2
  exit 1
fi

if [ -z "$IMAGE_NAME" ]; then
  echo "Image name is required (ensure --name is set)" >&2
  exit 1
fi

if [ -z "$IMAGE_PATH" ]; then
  echo "Image path is required (ensure --path is nonempty)" >&2
  exit 1
fi

if [ "${#IMAGE_TAGS[@]}" -eq 0 ]; then
  echo "Image tag is required (ensure --tag is passed at least once)" >&2
  exit 1
fi

docker_build_args=()

pushd "$IMAGE_PATH"
  if is_branch "main"; then
    echo "Running on main branch; building unconditionally"

    for tag in "${IMAGE_TAGS[@]}"; do
      docker_build_args+=(
        --tag="$REGISTRY_PRODUCTION/$IMAGE_NAME:$tag"
      )
    done

    run_trace $DRY_RUN docker build "$IMAGE_PATH" "${docker_build_args[@]}"

    if [ "$IMAGE_PUSH" == "true" ]; then
      for tag in "${IMAGE_TAGS[@]}"; do
        run_trace $DRY_RUN docker push "$REGISTRY_PRODUCTION/$IMAGE_NAME:$tag"
      done
    fi
  elif [ "$PULL_REQUEST" -gt 0 ]; then
    echo "Running in a pull request..."
    if ! files_changed "$IMAGE_PATH"; then
      echo "Files have not changed; re-tagging image"
      # Pull production images and re-tag them
      for tag in "${IMAGE_TAGS[@]}"; do
        run_trace $DRY_RUN docker pull "$REGISTRY_PRODUCTION/$IMAGE_NAME:$tag"
        run_trace $DRY_RUN docker tag "$REGISTRY_PRODUCTION/$IMAGE_NAME:$tag" "$REGISTRY_DEVELOPMENT/pr-$PULL_REQUEST/$IMAGE_NAME:$tag"
      done
    else
      echo "Files have changed; building image"

      for tag in "${IMAGE_TAGS[@]}"; do
        docker_build_args+=(
          --tag="$REGISTRY_DEVELOPMENT/pr-$PULL_REQUEST/$IMAGE_NAME:$tag"
          --build-arg=BASE_REGISTRY="$REGISTRY_DEVELOPMENT/pr-$PULL_REQUEST"
        )
      done

      run_trace $DRY_RUN docker build "$IMAGE_PATH" "${docker_build_args[@]}"
    fi

    if [ "$IMAGE_PUSH" == "true" ]; then
      for tag in "${IMAGE_TAGS[@]}"; do
        run_trace $DRY_RUN docker push "$REGISTRY_DEVELOPMENT/pr-$PULL_REQUEST/$IMAGE_NAME:$tag"
      done
    fi
  fi
popd
