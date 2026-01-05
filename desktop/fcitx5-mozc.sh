#!/usr/bin/env bash
set -eu

echo '[Current IME settings]'
echo "XMODIFIERS=${XMODIFIERS-}" # @im=ibus
echo "GTK_IM_MODULE=${GTK_IM_MODULE-}" # empty
echo "QT_IM_MODULE=${QT_IM_MODULE-}" # ibus

envdir="$HOME/.config/environment.d"

mkdir -p "$envdir"
cat > "$envdir/ime-fcitx5-mozc.conf" << 'EOF'
XMODIFIERS=@im=fcitx
# GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
EOF

sudo dnf -y install fcitx5-mozc fcitx5-autostart
sudo dnf -y upgrade fcitx5-mozc fcitx5-autostart

echo 'Log out and log back in, then run fcitx5-configtool to set up IME.'

