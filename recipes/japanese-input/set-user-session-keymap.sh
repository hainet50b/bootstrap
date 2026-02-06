#!/usr/bin/env bash
set -eu

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

gsettings get org.gnome.desktop.input-sources sources > "$tmpdir/before"
gsettings get org.gnome.desktop.input-sources mru-sources >> "$tmpdir/before"

layout=${1:-jp}
gsettings set org.gnome.desktop.input-sources sources "[('xkb','$layout')]"
gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb','$layout')]"

gsettings get org.gnome.desktop.input-sources sources > "$tmpdir/after"
gsettings get org.gnome.desktop.input-sources mru-sources >> "$tmpdir/after"

if diff -q "$tmpdir/before" "$tmpdir/after"; then
  echo 'No changes detected.'
else
  echo '[User Input Sources Changes]'
  diff -u "$tmpdir/before" "$tmpdir/after"
fi

