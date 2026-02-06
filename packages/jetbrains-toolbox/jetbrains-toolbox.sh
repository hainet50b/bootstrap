#!/usr/bin/env bash
set -eu

if [ -e "$HOME/.local/opt/jetbrains-toolbox/current/bin/build.txt" ]; then
    current_version=$(cat "${HOME}/.local/opt/jetbrains-toolbox/current/bin/build.txt")
else
  current_version='0.0.0.00000'
fi
tba=$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true' \
  | jq -r '.TBA[0]'
)
latest_version=$(echo "$tba" | jq -r '.build')

install_and_update_jetbrains_toolbox() {
  local tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  local linux=$(echo "$tba" | jq -r '.downloads.linux')

  local bin_link=$(echo "$linux" | jq -r '.link')
  local checksum_link=$(echo "$linux" | jq -r '.checksumLink')

  cd "$tmpdir"

  curl -fsSL -O "$bin_link"
  curl -fsSL -O "$checksum_link"

  sha256sum -c "jetbrains-toolbox-${latest_version}.tar.gz.sha256"

  local base_dir="${HOME}/.local"
  local bin_dir="${base_dir}/bin"
  local opt_dir="${base_dir}/opt/jetbrains-toolbox"

  mkdir -p "$bin_dir"
  mkdir -p "$opt_dir"

  local current_dir="${opt_dir}/current"
  local install_dir="${opt_dir}/${latest_version}"

  mkdir -p "$install_dir"

  tar -xzf "${tmpdir}/jetbrains-toolbox-${latest_version}.tar.gz" -C "$install_dir" --strip-components=1

  ln -sfn "$install_dir" "$current_dir"
  ln -sfn "${current_dir}/bin/jetbrains-toolbox" "${bin_dir}/jetbrains-toolbox"
}

if [ "$current_version" = '0.0.0.00000' ]; then
  echo "Installing JetBrains Toolbox: ${latest_version}"
  install_and_update_jetbrains_toolbox
elif [ "$current_version" = "$latest_version" ]; then
  echo "JetBrains Toolbox is up to date: ${current_version}"
else
  echo "Updating JetBrains Toolbox: ${current_version} -> ${latest_version}"
  install_and_update_jetbrains_toolbox
fi

