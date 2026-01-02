#!/usr/bin/env bash
set -eu

x11_conf='/etc/X11/xorg.conf.d/00-keyboard.conf'
vconsole_conf='/etc/vconsole.conf'

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cp -- "$x11_conf" "$tmpdir/00-keyboard.conf"
cp -- "$vconsole_conf" "$tmpdir/vconsole.conf"

layout=${1:-jp}
sudo localectl set-x11-keymap "$layout"

show_diff() {
  local label=$1 before=$2 after=$3

  echo "[$label]"

  if diff -q "$before" "$after" > /dev/null; then
    echo 'No changes detected.'
  else
    diff -u "$before" "$after" || :
  fi
}

show_diff "$x11_conf" "$tmpdir/00-keyboard.conf" "$x11_conf"
echo
show_diff "$vconsole_conf" "$tmpdir/vconsole.conf" "$vconsole_conf"

