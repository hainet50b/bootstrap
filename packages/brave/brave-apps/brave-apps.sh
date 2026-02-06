#!/usr/bin/env bash
set -e

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

cat "$HOME/.local/share/applications"/brave-* \
  | sed -n 's/.*Name=\([^\n]*\).*/\1/p' \
  | sort \
  > "${script_dir}/brave-apps.txt"

