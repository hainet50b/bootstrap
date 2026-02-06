#!/usr/bin/env bash
set -eu

if command -v obsidian > /dev/null 2>&1; then
  current_version=$(realpath "${HOME}/.local/bin/obsidian" \
    | sed -n 's/.*Obsidian-\(.*\).AppImage/\1/p'
  )
else
  current_version='0.0.0'
fi
latest_version=$(curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
  | sed -n 's/.*tag_name": "v\([^"]*\).*/\1/p'
)

install_and_update_obsidian() {
  local tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  local bin_name='Obsidian.AppImage'

  curl -fsSL \
    -o "${tmpdir}/${bin_name}" \
    "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian-${latest_version}.AppImage"
  chmod +x "${tmpdir}/${bin_name}"

  local base_dir="${HOME}/.local"
  local bin_dir="${base_dir}/bin"
  local opt_dir="${base_dir}/opt/obsidian"

  mkdir -p "$bin_dir"
  mkdir -p "$opt_dir"

  local current_dir="${opt_dir}/current"
  local install_dir="${opt_dir}/${latest_version}"

  mkdir -p "$install_dir"

  mv "${tmpdir}/${bin_name}" "${install_dir}"

  ln -sfn "$install_dir" "$current_dir"
  ln -sfn "${current_dir}/${bin_name}" "${bin_dir}/obsidian"
}

if [ "$current_version" = '0.0.0' ]; then
  echo "Installing Obsidian: ${latest_version}"
  install_and_update_obsidian
elif [ "$current_version" = "$latest_version" ]; then
  echo "Obsidian is up to date: ${current_version}"
else
  echo "Updating Obsidian: ${current_version} -> ${latest_version}"
  install_and_update_obsidian
fi

