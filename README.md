# <img src="https://raw.githubusercontent.com/pipery-dev/pipery-cpp-ci/main/assets/icon.png" alt="Pipery C/C++ CI" width="28" align="center" /> Pipery C/C++ CI

Reusable GitHub Action for a complete C/C++ CI pipeline with structured logging via [Pipery](https://pipery.dev).

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20C/C++%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-cpp-ci)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Table of Contents

- [Quick Start](#quick-start)
- [Pipeline Overview](#pipeline-overview)
- [Configuration Options](#configuration-options)
- [Usage Examples](#usage-examples)
- [GitLab CI](#gitlab-ci)
- [Bitbucket Pipelines](#bitbucket-pipelines)
- [About Pipery](#about-pipery)
- [Development](#development)

## Quick Start

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-cpp-ci@v1
        with:
          project_path: .
          build_system: auto
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Pipeline Overview

| Step | Tool | Skip Input | Description |
| --- | --- | --- | --- |
| Lint | clang-tidy | `skip_lint` | Enforces code style and detects issues |
| SAST | cppcheck, clang-analyzer | `skip_sast` | Detects C/C++ vulnerabilities |
| SCA | dependency-check | `skip_sca` | Identifies vulnerable dependencies |
| Build | CMake/Make/Meson | `skip_build` | Compiles C/C++ project |
| Test | ctest | `skip_test` | Runs unit and integration tests |
| Version | Semantic versioning | `skip_versioning` | Bumps version and creates git tag |
| Package | cpack | `skip_packaging` | Creates distributable artifacts |
| Release | GitHub Release | `skip_release` | Publishes binaries to GitHub |
| Reintegrate | Git merge | `skip_reintegration` | Merges back to default branch |

## Configuration Options

| Name | Default | Description |
| --- | --- | --- |
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `.pipery/config.yaml` | Path to Pipery config file. |
| `build_system` | `auto` | Build system to use: `auto`, `cmake`, `make`, or `meson`. |
| `compiler` | `g++` | C++ compiler to use (e.g., `g++`, `clang++`). |
| `cmake_flags` | `` | Extra flags to pass to the cmake configure step. |
| `target_platforms` | `` | Comma or whitespace separated `OS/ARCH` targets for cross-platform compilation, e.g. `linux/amd64,windows/amd64,darwin/arm64`. Empty builds the host platform. Targeted CMake builds set `CMAKE_SYSTEM_NAME` and `CMAKE_SYSTEM_PROCESSOR`; the runner must provide the matching toolchain or you can pass one through `cmake_flags`. |
| `tests_path` | `` | Test filter pattern passed to ctest -R or equivalent. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `target_branch` | `main` | Target branch for reintegration. |
| `github_token` | `` | GitHub token for release and reintegration. |
| `log_file` | `pipery.jsonl` | Path to the JSONL structured log file. |
| `skip_lint` | `false` | Skip the lint step. |
| `skip_sast` | `false` | Skip the SAST step. |
| `skip_sca` | `false` | Skip the SCA step. |
| `skip_build` | `false` | Skip the build step. |
| `skip_test` | `false` | Skip the test step. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip the packaging step. |
| `skip_release` | `false` | Skip the release step. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

## Usage Examples

### Example 1: CMake project with g++

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-cpp-ci@v1
        with:
          project_path: .
          build_system: cmake
          compiler: g++
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 2: Clang compiler

```yaml
- uses: pipery-dev/pipery-cpp-ci@v1
  with:
    project_path: .
    build_system: cmake
    compiler: clang++
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 3: Custom CMake flags for release build

```yaml
- uses: pipery-dev/pipery-cpp-ci@v1
  with:
    project_path: .
    build_system: cmake
    cmake_flags: -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=ON -DENABLE_DOCS=ON
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 4: Cross-platform CMake build

```yaml
- uses: pipery-dev/pipery-cpp-ci@v1
  with:
    project_path: .
    build_system: cmake
    target_platforms: linux/amd64,windows/amd64
    cmake_flags: -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/mingw.cmake
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 5: Makefile-based project

```yaml
- uses: pipery-dev/pipery-cpp-ci@v1
  with:
    project_path: .
    build_system: make
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 6: Run specific test suite

```yaml
- uses: pipery-dev/pipery-cpp-ci@v1
  with:
    project_path: .
    tests_path: unit_*
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 6: Major version bump

```yaml
- uses: pipery-dev/pipery-cpp-ci@v1
  with:
    project_path: .
    build_system: cmake
    version_bump: major
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## GitLab CI

This repository includes a GitLab CI equivalent at `.gitlab-ci.yml`. Copy it into a GitLab project or use it as a reference implementation for running the same Pipery pipeline outside GitHub Actions.

The GitLab pipeline maps action inputs to CI/CD variables, publishes `pipery.jsonl` as an artifact, and maintains the same skip controls. Store credentials as protected GitLab CI/CD variables.

```yaml
include:
  - remote: https://raw.githubusercontent.com/pipery-dev/pipery-cpp-ci/v1/.gitlab-ci.yml
```

### GitLab CI Variables

Configure these protected variables in **Settings > CI/CD > Variables**:

- `GITHUB_TOKEN` - GitHub API access for release and reintegration
- `BUILD_SYSTEM` - cmake/make/meson (default: auto)
- `COMPILER` - C++ compiler (default: g++)
- `VERSION_BUMP` - patch/minor/major (default: patch)

## Bitbucket Pipelines

Bitbucket Cloud pipelines provide an alternative to GitHub Actions. The equivalent pipeline configuration is in `bitbucket-pipelines.yml`.

### Getting Started

1. Copy `bitbucket-pipelines.yml` to your Bitbucket repository root
2. Configure Protected Variables in **Repository Settings > Pipelines > Repository Variables**:
   - `GITHUB_TOKEN` - GitHub API access (for release and reintegration)
   - `BUILD_SYSTEM` - cmake/make/meson (default: auto)
   - `COMPILER` - C++ compiler (default: g++)
3. Commit and push to trigger the pipeline

### Pipeline Stages

The Bitbucket equivalent follows the same structure:

checkout → setup → lint (clang-tidy) → SAST (cppcheck) → SCA (dependency-check) → build → test → versioning → packaging → release → reintegration → logs

### Skip Flags

Disable any stage using environment variables:

- `SKIP_LINT`, `SKIP_SAST`, `SKIP_SCA`, `SKIP_BUILD`, `SKIP_TEST`, `SKIP_VERSIONING`, `SKIP_PACKAGING`, `SKIP_RELEASE`, `SKIP_REINTEGRATION`

Example: Set `SKIP_SAST=true` to skip security scanning.

### Features

- Auto-detects CMake, Make, Meson build systems
- Multiple compiler support (g++, clang++)
- Static analysis (clang-tidy, cppcheck)
- Dependency vulnerability checking
- Automatic GitHub releases
- JSONL-based pipeline logging
- 30-90 day artifact retention

## About Pipery

<img src="https://avatars.githubusercontent.com/u/270923927?s=32" alt="Pipery" width="22" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

- Browse logs in the [Pipery Dashboard](https://github.com/pipery-dev/pipery-dashboard)
- Find all Pipery actions on [GitHub Marketplace](https://github.com/marketplace?q=pipery&type=actions)
- Source code: [pipery-dev](https://github.com/pipery-dev)

## Development

```bash
# Run the action locally against test-project/
pipery-actions test --repo .

# Regenerate docs
pipery-actions docs --repo .

# Dry-run release
pipery-actions release --repo . --dry-run
```
