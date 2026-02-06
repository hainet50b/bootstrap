#!/usr/bin/env bash
set -eu

GITHUB_LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | sed -n 's/.*tag_name\": \"v\([^\"]*\).*/\1/p')
os=$(uname -s | tr 'A-Z' 'a-z')
arch=$(uname -m)

GITHUB_FILE="lazygit_${GITHUB_LATEST_VERSION}_${os}_${arch}.tar.gz"
GITHUB_URL="https://github.com/jesseduffield/lazygit/releases/download/v${GITHUB_LATEST_VERSION}/${GITHUB_FILE}"

LAZYGIT_CURRENT_VERSION='0.0.0'
if command -v lazygit > /dev/null 2>&1; then
  LAZYGIT_CURRENT_VERSION=$(lazygit -v | sed -n 's/.*, version=\([^,]*\).*/\1/p')
fi

if [ "$LAZYGIT_CURRENT_VERSION" = "$GITHUB_LATEST_VERSION" ]; then
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL -o "$tmpdir/lazygit.tar.gz" "$GITHUB_URL"
tar -xzf "$tmpdir/lazygit.tar.gz" -C "$tmpdir" lazygit

mkdir -p "$HOME/.local/bin"
install -m 755 "$tmpdir/lazygit" "$HOME/.local/bin/lazygit"

