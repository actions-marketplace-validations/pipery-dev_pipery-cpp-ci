#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${INPUT_CONFIG_FILE:-.pipery/config.yaml}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: $CONFIG_FILE (skipping)"
  exit 0
fi

if ! command -v python3 &>/dev/null; then
  echo "python3 not available, skipping config parsing."
  exit 0
fi

python3 - "$CONFIG_FILE" <<'EOF'
import sys
import os

config_file = sys.argv[1]

try:
    import yaml
except ImportError:
    print("PyYAML not available, skipping config parsing.")
    sys.exit(0)

try:
    with open(config_file) as f:
        data = yaml.safe_load(f) or {}
except Exception as exc:
    print(f"Failed to parse config file: {exc}", file=sys.stderr)
    sys.exit(0)

for key, value in data.items():
    env_name = f"INPUT_{key.upper()}"
    if env_name not in os.environ:
        github_env = os.environ.get("GITHUB_ENV", "")
        if github_env:
            with open(github_env, "a") as f:
                f.write(f"{env_name}={value}\n")
        else:
            print(f"export {env_name}={value!r}")
EOF
