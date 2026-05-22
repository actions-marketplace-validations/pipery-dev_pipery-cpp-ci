# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- Added `target_platforms` input for C/C++ per-target build directories and packaging.

## [1.0.0] - 2026-04-27

### Added
- GitHub Marketplace branding icon updated to match action technology (Feather icon set)
- Added `simple_icon` field to `pipery-action.toml` for technology icon reference (Simple Icons slug)

### Added
- Initial implementation of the C/C++ CI action
- `build_system` input: auto-detects CMake, make, or meson
- `compiler` input: configures the C++ compiler (default `g++`)
- `cmake_flags` input: passes extra flags to the CMake configure step
- `tests_path` input: filter pattern forwarded to `ctest -R`
- Short git hash (`sha-<7chars>`) included in every release alongside semver tags

### Changed
- All step scripts use `#!/usr/bin/env psh` as the shebang
- `setup-psh.sh` detects runner architecture dynamically (amd64 and arm64)

## [0.1.0] - Initial scaffold
