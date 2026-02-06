#!/usr/bin/env bash
set -eu

if command -v nvim > /dev/null 2>&1; then
  current_version=$(nvim --version | head -n 1 | awk '{print $2}')
else
  current_version='v0.0.0'
fi
latest_version=$(curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/neovim/neovim/releases/latest \
  | sed -n 's/.*tag_name": "\([^"]*\).*/\1/p'
)

install_and_update_neovim() {
  local tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL \
    -o "${tmpdir}/nvim-linux-x86_64.tar.gz" \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

  local base_dir="${HOME}/.local"
  local bin_dir="${base_dir}/bin"
  local opt_dir="${base_dir}/opt/neovim"

  mkdir -p "$bin_dir"
  mkdir -p "$opt_dir"

  local current_dir="${opt_dir}/current"
  local install_dir="${opt_dir}/${latest_version}"

  mkdir -p "$install_dir"

  tar -xzf "${tmpdir}/nvim-linux-x86_64.tar.gz" -C "$install_dir" --strip-components=1

  ln -sfn "$install_dir" "$current_dir"
  ln -sfn "${current_dir}/bin/nvim" "${bin_dir}/nvim"
}

if [ "$current_version" = 'v0.0.0' ]; then
  echo "Installing Neovim: ${latest_version}"
  install_and_update_neovim
elif [ "$current_version" = "$latest_version" ]; then
  echo "Neovim is up to date: ${current_version}"
else
  echo "Updating Neovim: ${current_version} -> ${latest_version}"
  install_and_update_neovim
fi

