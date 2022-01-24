#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)
source "$PROJECT_ROOT/lib/default_branch.sh"
source "$PROJECT_ROOT/lib/files_changed.sh"
source "$PROJECT_ROOT/lib/trace.sh"


