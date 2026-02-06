#!/usr/bin/env bash
set -e

echo '[PCI devices: NVIDIA]'
lspci | grep -i nvidia || true

echo '[Kernel modules: NVIDIA]'
lsmod | grep nvidia || true

echo '[Kernel modules: Nouveau]'
lsmod | grep nouveau || true

sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda

sudo akmods --rebuild --force

cat << 'EOF'
Reboot to load the NVIDIA kernel modules.
After reboot, you can check with:
  nvidia-smi
  lsmod | grep -i nvidia
EOF

