#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
BUILD_SYSTEM="${INPUT_BUILD_SYSTEM:-auto}"
CMAKE_FLAGS="${INPUT_CMAKE_FLAGS:-}"
TARGET_PLATFORMS="${INPUT_TARGET_PLATFORMS:-}"
COMPILER="${INPUT_COMPILER:-}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"

cd "$PROJECT"

_detect_build_system() {
  if [ -f "CMakeLists.txt" ]; then
    echo "cmake"
  elif [ -f "meson.build" ]; then
    echo "meson"
  elif [ -f "Makefile" ]; then
    echo "make"
  else
    echo "unknown"
  fi
}

if [ "$BUILD_SYSTEM" = "auto" ]; then
  BUILD_SYSTEM="$(_detect_build_system)"
fi

echo "Building with: $BUILD_SYSTEM"

_platforms() {
  if [ -n "$TARGET_PLATFORMS" ]; then
    printf '%s\n' "$TARGET_PLATFORMS" | sed 's/[[:space:],][[:space:],]*/\
/g; /^$/d'
  else
    printf 'host/host\n'
  fi
}

_cmake_system_name() {
  case "$1" in
    linux) echo "Linux" ;;
    windows) echo "Windows" ;;
    darwin|macos) echo "Darwin" ;;
    *) echo "$1" ;;
  esac
}

_build_one() {
  PLATFORM="$1"
  if [ "$PLATFORM" = "host/host" ]; then
    OS="host"
    ARCH="host"
    BUILD_DIR="build"
    TARGET_ARGS=()
  else
    OS="${PLATFORM%/*}"
    ARCH="${PLATFORM#*/}"
    if [ -z "$OS" ] || [ -z "$ARCH" ] || [ "$OS" = "$ARCH" ]; then
      echo "Invalid target platform '$PLATFORM'. Expected OS/ARCH, e.g. linux/amd64." >&2
      exit 1
    fi
    BUILD_DIR="build/${OS}-${ARCH}"
    TARGET_ARGS=("-DPIPERY_TARGET_OS=${OS}" "-DPIPERY_TARGET_ARCH=${ARCH}")
  fi

  echo "Compiling target ${PLATFORM} into ${BUILD_DIR}..."

  case "$BUILD_SYSTEM" in
    cmake)
      CMAKE_ARGS=("-B" "$BUILD_DIR")
      if [ "$PLATFORM" != "host/host" ]; then
        CMAKE_ARGS+=("-DCMAKE_SYSTEM_NAME=$(_cmake_system_name "$OS")" "-DCMAKE_SYSTEM_PROCESSOR=${ARCH}")
      fi
      if [ -n "$COMPILER" ]; then
        CMAKE_ARGS+=("-DCMAKE_CXX_COMPILER=${COMPILER}")
      fi
      # shellcheck disable=SC2206
      EXTRA_CMAKE_FLAGS=(${CMAKE_FLAGS:-})
      cmake "${CMAKE_ARGS[@]}" "${TARGET_ARGS[@]}" "${EXTRA_CMAKE_FLAGS[@]}" .
      cmake --build "$BUILD_DIR"
      ;;
    make)
      make TARGET_OS="$OS" TARGET_ARCH="$ARCH" BUILD_DIR="$BUILD_DIR"
      ;;
    meson)
      meson setup "$BUILD_DIR" "${TARGET_ARGS[@]}"
      meson compile -C "$BUILD_DIR"
      ;;
    *)
      echo "ERROR: Could not detect build system (no CMakeLists.txt, Makefile, or meson.build found)." >&2
      exit 1
      ;;
  esac

  printf '{"event":"cross_compile","status":"success","language":"cpp","target":"%s","build_dir":"%s"}\n' "$PLATFORM" "$BUILD_DIR" >> "$LOG"
}

for PLATFORM in $(_platforms); do
  _build_one "$PLATFORM"
done

mkdir -p dist
find build -maxdepth 2 -type f -executable ! -name '*.so' ! -name '*.a' -exec cp {} dist/ \; 2>/dev/null || true
echo "Build complete. Artifacts in dist/:"
ls dist/ 2>/dev/null || true
