# Pipery C/C++ CI

CI pipeline for C/C++: SAST, SCA, lint, build, test, versioning, packaging, release, reintegration

## Status

- Owner: `pipery-dev`
- Repository: `pipery-cpp-ci`
- Marketplace category: `continuous-integration`
- Current version: `1.0.1`

## Usage

```yaml
name: Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-cpp-ci@v1
        with:
          project_path: .
          config_file: .pipery/config.yaml
          build_system: auto
          tests_path: 
          compiler: g++
          cmake_flags: 
          target_platforms: 
          github_token: 
          version_bump: patch
          log_file: pipery.jsonl
          target_branch: main
          skip_sast: false
          skip_sca: false
          skip_lint: false
          skip_build: false
          skip_test: false
          skip_versioning: false
          skip_packaging: false
          skip_release: false
          skip_reintegration: false
```

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `project_path` | no | `.` | Path to the project source tree the action should operate on. |
| `config_file` | no | `.pipery/config.yaml` | Path to Pipery config file. |
| `build_system` | no | `auto` | Build system to use: auto, cmake, make, or meson. |
| `tests_path` | no | `` | Test filter pattern passed to ctest -R or equivalent. |
| `compiler` | no | `g++` | C++ compiler to use (e.g. g++, clang++). |
| `cmake_flags` | no | `` | Extra flags to pass to the cmake configure step. |
| `target_platforms` | no | `` | Comma or whitespace separated OS/ARCH targets for cross-platform compilation, e.g. linux/amd64,windows/amd64,darwin/arm64. Empty builds the host platform. |
| `github_token` | no | `` | GitHub token for release and reintegration steps. |
| `version_bump` | no | `patch` | Version bump type: patch, minor, or major. |
| `log_file` | no | `pipery.jsonl` | Path to the JSONL log file written during the run. |
| `target_branch` | no | `main` | Target branch for reintegration. |
| `skip_sast` | no | `false` | Skip SAST step. |
| `skip_sca` | no | `false` | Skip SCA step. |
| `skip_lint` | no | `false` | Skip lint step. |
| `skip_build` | no | `false` | Skip build step. |
| `skip_test` | no | `false` | Skip test step. |
| `skip_versioning` | no | `false` | Skip versioning step. |
| `skip_packaging` | no | `false` | Skip packaging step. |
| `skip_release` | no | `false` | Skip release step. |
| `skip_reintegration` | no | `false` | Skip reintegration step. |

## Outputs

No outputs.

## Development

This repository is managed with `pipery-tooling`.

```bash
pipery-actions test --repo .
pipery-actions docs --repo .
pipery-actions release --repo . --dry-run
```

By default, `pipery-actions test --repo .` executes the action against `test-project` and validates `pipery.jsonl`.

## Marketplace Release Flow

1. Update the implementation and changelog.
2. Run `pipery-actions release --repo .`.
3. Push the created git tag and major tag alias.
4. Publish the GitHub release.
