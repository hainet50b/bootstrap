#!/usr/bin/env bash
set -eu

latest_version=$(curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/nvm-sh/nvm/releases/latest \
  | sed -n 's/.*tag_name": "\([^"]*\).*/\1/p'
)

curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${latest_version}/install.sh" | bash

