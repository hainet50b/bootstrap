#!/usr/bin/env bash
set -e

sudo dnf -y install dnf-plugins-core
sudo dnf -y config-manager addrepo --overwrite \
  --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

sudo dnf -y install brave-browser
sudo dnf -y upgrade brave-browser

