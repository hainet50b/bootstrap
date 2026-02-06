#!/usr/bin/env bash
set -e

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

gnome-extensions list --enabled \
  | sort \
  > "${script_dir}/gnome-extensions.txt"

