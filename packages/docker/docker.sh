#!/usr/bin/env bash
set -eu

sudo dnf -y remove \
  docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
fi

sudo dnf -y install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable --now docker

if ! groups | grep -q docker; then
  sudo usermod -aG docker $USER
  echo "NOTE: Added $USER to the docker group. Log out and back in to apply."
fi

sudo dnf -y upgrade \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

