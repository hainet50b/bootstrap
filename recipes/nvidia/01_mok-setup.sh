#!/usr/bin/env bash
set -e

sudo dnf -y install akmods mokutil

if ! sudo [ -e /etc/pki/akmods/certs/public_key.der ]; then
  sudo kmodgenca -a
fi

echo '[akmods certs]'
sudo ls -la /etc/pki/akmods/certs

sudo mokutil --import /etc/pki/akmods/certs/public_key.der

echo '[Pending MOK enrollment]'
sudo mokutil --list-new || true

cat << 'EOF'
Reboot your computer to enroll the MOK you just imported.
On boot, you will see the blue MOK Manager screen.
Select:
  Enroll MOK -> Continule -> Yes -> (enter the password you set) -> OK
After enrollment, you can check with:
  sudo mokutil --list-enrolled
EOF

