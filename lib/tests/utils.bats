#!/usr/bin/env bats

SCRIPT_NAME="utils.sh"
SCRIPT=$(realpath "$BATS_TEST_DIRNAME"/../"$SCRIPT_NAME")
source "$SCRIPT"

@test "$SCRIPT_NAME: check_dependencies with git" {
  run check_dependencies git
  [ "$status" -eq 0 ]
}

@test "$SCRIPT_NAME: check_dependencies with nonexistent command" {
  run check_dependencies no-such-command
  [ "$status" -eq 1 ]
}
