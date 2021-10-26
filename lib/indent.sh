#!/usr/bin/env bash

set -euo pipefail

# Indent output by (indent) levels
#
# Example:
#   echo "example" | indent 2
#   cat file.txt | indent
function indent() {
  local indentSize=2
  local indent=1
  if [ -n "${1:-}" ]; then
    indent="$1"
  fi
  pr --omit-header --indent=$((indent * indentSize))
}
