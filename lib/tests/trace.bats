#!/usr/bin/env bats

SCRIPT_NAME="trace.sh"
SCRIPT=$(realpath "$BATS_TEST_DIRNAME"/../"$SCRIPT_NAME")
source "$SCRIPT"

@test "$SCRIPT_NAME: dry run with nonexistent command" {
  GITHUB_ACTIONS="" run run_trace true no-such-command --flag --value
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "+ no-such-command --flag --value" ]
}

@test "$SCRIPT_NAME: run with nonexistent command" {
  GITHUB_ACTIONS="" run run_trace false no-such-command
  [ "$status" -eq 127 ]
  [ "${lines[0]}" = "+ no-such-command" ]
}

@test "$SCRIPT_NAME: run with md5sum" {
  GITHUB_ACTIONS="" run run_trace false echo '"The quick brown fox jumps over the lazy dog"' \| md5sum
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "+ echo \"The quick brown fox jumps over the lazy dog\" | md5sum" ]
  [ "${lines[1]}" = "37c4b87edffc5d198ff5a185cee7ee09  -" ]
}

@test "$SCRIPT_NAME: grouped output in GitHub Actions" {
  GITHUB_ACTIONS="true" run run_trace false echo '"hello world"'
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '::group::Run echo "hello world"' ]
  [ "${lines[1]}" = "hello world" ]
  [ "${lines[2]}" = "::endgroup::" ]
}
