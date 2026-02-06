#!/usr/bin/env bash
set -eu

if command -v codium > /dev/null 2>&1; then
  current_version=$(codium -v | head -n 1)
else
  current_version='0.0.0'
fi
releases=$(curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/VSCodium/vscodium/releases/latest
)
latest_version=$(echo "$releases" | jq -r '.tag_name')

install_and_update_vscodium() {
  (
    local tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' RETURN

    local assets=$(echo "$releases" | jq -r '.assets[]')

    local bin_link=$(echo "$assets" \
      | jq -r "select(.name == \"VSCodium-linux-x64-${latest_version}.tar.gz\") | .browser_download_url"
    )
    local checksum_link=$(echo "$assets" \
      | jq -r "select(.name == \"VSCodium-linux-x64-${latest_version}.tar.gz.sha256\") | .browser_download_url"
    )

    cd "$tmpdir"

    curl -fsSL -O "$bin_link"
    curl -fsSL -O "$checksum_link"

    sha256sum -c "VSCodium-linux-x64-${latest_version}.tar.gz.sha256"

    local base_dir="${HOME}/.local"
    local bin_dir="${base_dir}/bin"
    local opt_dir="${base_dir}/opt/vscodium"

    mkdir -p "$bin_dir"
    mkdir -p "$opt_dir"

    local current_dir="${opt_dir}/current"
    local install_dir="${opt_dir}/${latest_version}"

    mkdir -p "$install_dir"

    tar -xzf "${tmpdir}/VSCodium-linux-x64-${latest_version}.tar.gz" -C "$install_dir"

    ln -sfn "$install_dir" "$current_dir"
    ln -sfn "${current_dir}/bin/codium" "${bin_dir}/codium"
  )

  mkdir -p ~/.local/share/icons/hicolor/256x256/apps

  ln -sf \
    ~/.local/opt/vscodium/current/resources/app/resources/linux/code.png \
    ~/.local/share/icons/hicolor/256x256/apps/vscodium.png

  mkdir -p ~/.local/share/applications
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  cp -f "${script_dir}/vscodium.desktop" ~/.local/share/applications/vscodium.desktop

  update-desktop-database  ~/.local/share/applications/ 2> /dev/null || true
}

if [ "$current_version" = '0.0.0' ]; then
  echo "Installing VSCodium: ${latest_version}"
  install_and_update_vscodium
elif [ "$current_version" = "$latest_version" ]; then
  echo "VSCodium is up to date: ${current_version}"
else
  echo "Updating VSCodium: ${current_version} -> ${latest_version}"
  install_and_update_vscodium
fi

