#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

say() { printf "\n==> %s\n" "$*"; }

say "Copiando configs del sistema al repo..."

mkdir -p "$REPO_ROOT/configs/udev" "$REPO_ROOT/configs/modules-load" "$REPO_ROOT/configs/lightdm"

sudo cp -f /etc/udev/rules.d/99-uinput.rules "$REPO_ROOT/configs/udev/99-uinput.rules"
sudo cp -f /etc/modules-load.d/uinput.conf "$REPO_ROOT/configs/modules-load/uinput.conf"
sudo cp -f /etc/lightdm/lightdm.conf "$REPO_ROOT/configs/lightdm/lightdm.conf"

mkdir -p "$REPO_ROOT/configs/systemd-user"
if [[ -f "$HOME/.config/systemd/user/sunshine.service" ]]; then
  cp -f "$HOME/.config/systemd/user/sunshine.service" "$REPO_ROOT/configs/systemd-user/sunshine.service"
fi

say "Hecho. Revisa git diff y commitea."
