#!/usr/bin/env bash
set -eu

if rpm -q proton-pass > /dev/null 2>&1; then
  current_version=$(rpm -q --qf '%{VERSION}\n' proton-pass)
else
  current_version='0.0.0'
fi

latest_release=$(curl -fsSL https://proton.me/download/PassDesktop/linux/x64/version.json \
  | jq '
    .Releases
      | map(select(.CategoryName == "Stable"))
      | max_by(.Version | split(".") | map(tonumber))
  '
)
latest_version=$(echo $latest_release | jq -r '.Version')

install_and_update_proton_pass() {
  local tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL \
    -o "${tmpdir}/ProtonPass.rpm" \
    https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm

  rpm_release=$(echo $latest_release | jq '.File[] | select(.Identifier | contains(".rpm"))')
  sha512checksum=$(echo $rpm_release | jq -r '.Sha512CheckSum')
  echo "${sha512checksum} ${tmpdir}/ProtonPass.rpm" | sha512sum --check -

  sudo dnf -y install "${tmpdir}/ProtonPass.rpm"
}

if [ "$current_version" = '0.0.0' ]; then
  echo "Installing Proton Pass: ${latest_version}"
  install_and_update_proton_pass
elif [ "$current_version" = "$latest_version" ]; then
  echo "Proton Pass is up to date: ${current_version}"
else
  echo "Updating Proton Pass: ${current_version} -> ${latest_version}"
  install_and_update_proton_pass
fi

