#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"

cd "$PROJECT"

mkdir -p dist

PROJECT_NAME="$(basename "$(pwd)")"
VERSION="${INPUT_VERSION:-0.0.0}"
TARGET_PLATFORMS="${INPUT_TARGET_PLATFORMS:-}"

if [ -n "$TARGET_PLATFORMS" ]; then
  for PLATFORM in $(printf '%s\n' "$TARGET_PLATFORMS" | sed 's/[[:space:],][[:space:],]*/\
/g; /^$/d'); do
    OS="${PLATFORM%/*}"
    ARCH="${PLATFORM#*/}"
    BUILD_DIR="build/${OS}-${ARCH}"
    if [ ! -d "$BUILD_DIR" ]; then
      echo "Build directory not found for target $PLATFORM: $BUILD_DIR" >&2
      exit 1
    fi
    TARBALL="dist/${PROJECT_NAME}-${VERSION}-${OS}-${ARCH}.tar.gz"
    tar -czf "$TARBALL" "$BUILD_DIR"
    echo "Package created: $TARBALL"
    printf '{"event":"package","status":"success","artifact":"%s","target":"%s"}\n' "$TARBALL" "$PLATFORM" >> "$LOG"
  done
else
  TARBALL="dist/${PROJECT_NAME}-${VERSION}.tar.gz"
  tar -czf "$TARBALL" build/
  echo "Package created: $TARBALL"
  printf '{"event":"package","status":"success","artifact":"%s"}\n' "$TARBALL" >> "$LOG"
fi
