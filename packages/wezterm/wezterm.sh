#!/usr/bin/env bash
set -e

sudo dnf -y copr enable wezfurlong/wezterm-nightly
sudo dnf -y install wezterm
sudo dnf -y upgrade wezterm

