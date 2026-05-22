#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION_PATH="${GITHUB_ACTION_PATH:-$(cd "$SCRIPT_DIR/.." && pwd)}"

INPUT_PROJECT_PATH="${INPUT_PROJECT_PATH:-${PIPERY_TEST_PROJECT_PATH:-.}}"
INPUT_LOG_FILE="${INPUT_LOG_FILE:-${PIPERY_LOG_PATH:-pipery.jsonl}}"

export INPUT_PROJECT_PATH
export INPUT_LOG_FILE

if [ ! -d "$INPUT_PROJECT_PATH" ]; then
  echo "ERROR: Project path does not exist: $INPUT_PROJECT_PATH" >&2
  exit 1
fi

INPUT_PROJECT_PATH="$(cd "$INPUT_PROJECT_PATH" && pwd)"
export INPUT_PROJECT_PATH

if [ -d "$INPUT_PROJECT_PATH/bin" ]; then
  export PATH="$INPUT_PROJECT_PATH/bin:$PATH"
fi

if [ -d "$INPUT_PROJECT_PATH/mock-bin" ]; then
  export PATH="$INPUT_PROJECT_PATH/mock-bin:$PATH"
fi

echo "Starting C/C++ CI pipeline for: $INPUT_PROJECT_PATH"
echo "Log file: $INPUT_LOG_FILE"

  # In test mode use a bash wrapper for psh; the real psh binary has a Go runtime
  # incompatibility (newosproc) with the GitHub Actions runner seccomp profile.
  mkdir -p /tmp/pipery-test-bin
  printf '#!/bin/bash\nexec bash "$@"\n' > /tmp/pipery-test-bin/psh
  chmod +x /tmp/pipery-test-bin/psh
  export PATH="/tmp/pipery-test-bin:$PATH"


if [ -f "$ACTION_PATH/src/read-config.sh" ]; then
  bash "$ACTION_PATH/src/read-config.sh" || true
fi

if [ "${INPUT_SKIP_LINT:-false}" != "true" ]; then
  echo "--- Step: Lint ---"
  "$ACTION_PATH/src/step-lint.sh"
fi

if [ "${INPUT_SKIP_SAST:-false}" != "true" ]; then
  echo "--- Step: SAST ---"
  "$ACTION_PATH/src/step-sast.sh" || true
fi

if [ "${INPUT_SKIP_SCA:-false}" != "true" ]; then
  echo "--- Step: SCA ---"
  "$ACTION_PATH/src/step-sca.sh" || true
fi

if [ "${INPUT_SKIP_BUILD:-false}" != "true" ]; then
  echo "--- Step: Build ---"
  "$ACTION_PATH/src/step-build.sh"
fi

if [ "${INPUT_SKIP_TEST:-false}" != "true" ]; then
  echo "--- Step: Test ---"
  "$ACTION_PATH/src/step-test.sh"
fi

if [ "${INPUT_SKIP_VERSIONING:-false}" != "true" ]; then
  echo "--- Step: Version ---"
  "$ACTION_PATH/src/step-version.sh" || true
fi

if [ "${INPUT_SKIP_PACKAGING:-false}" != "true" ]; then
  echo "--- Step: Package ---"
  "$ACTION_PATH/src/step-package.sh"
fi

if [ "${INPUT_SKIP_RELEASE:-false}" != "true" ]; then
  echo "--- Step: Release ---"
  "$ACTION_PATH/src/step-release.sh" || true
fi

if [ "${INPUT_SKIP_REINTEGRATION:-false}" != "true" ]; then
  echo "--- Step: Reintegrate ---"
  "$ACTION_PATH/src/step-reintegrate.sh" || true
fi

printf '{"event":"build","status":"success","project":"cpp","mode":"ci"}\n' >> "${INPUT_LOG_FILE:-pipery.jsonl}"

echo "C/C++ CI pipeline complete."
