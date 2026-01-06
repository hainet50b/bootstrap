#!/usr/bin/env bash
set -eu

if command -v proton-authenticator > /dev/null 2>&1; then
  current_version=$(rpm -q --qf '%{VERSION}\n' proton-authenticator)
else
  current_version='0.0.0'
fi

latest=$(curl -fsSL https://proton.me/download/authenticator/linux/version.json \
  | jq '.Releases[0]'
)
latest_version=$(echo "$latest" | jq -r '.Version')

install_proton_authenticator() {
  local tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  local package="${tmpdir}/ProtonAuthenticator.rpm"

  curl -fsSL \
    -o "$package" \
    https://proton.me/download/authenticator/linux/ProtonAuthenticator.rpm

  local checksum=$(echo "$latest" | jq --arg latest_version "$latest_version" -r '
    .File[]
      | select(.Identifier | contains(".rpm"))
      | .Sha512CheckSum
    '
  )

  echo "${checksum} ${package}" | sha512sum -c -

  sudo dnf -y install "$package"
}

if [ "$current_version" = '0.0.0' ]; then
  echo "Installing Proton Authenticator: ${latest_version}"
  install_proton_authenticator
elif [ "$current_version" = "$latest_version" ]; then
  echo "Proton Authenticator is up to date: ${current_version}"
else
  echo "Updating proton Authenticator: ${current_version} -> ${latest_version}"
  install_proton_authenticator
fi

