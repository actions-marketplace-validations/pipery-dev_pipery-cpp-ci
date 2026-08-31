# Using Pipery C/C++ CI

CI pipeline for C/C++: SAST, SCA, lint, build, test, versioning, packaging, release, reintegration

## Recommended workflow

1. Pin the action to a major tag in production workflows.
2. Keep a representative test project in the repository and point `test_project_path` at it.
3. Emit a `pipery.jsonl` build log during the action run and keep `test_log_path` pointed at it.
4. Make the action consume that path via the configured test input.
5. Keep changelog entries under `## [Unreleased]` until you cut a release.
6. Regenerate docs before publishing a new version.

## Example

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
