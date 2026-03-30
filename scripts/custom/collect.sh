#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SYSTEM_CONFIG_DIR="$REPO_ROOT/configs/system"
SYSTEMD_USER_CONFIG_DIR="$REPO_ROOT/configs/systemd-user"

say() { printf "\n==> %s\n" "$*"; }
warn() { printf "\n[WARN] %s\n" "$*"; }

say "Copiando configs del sistema al repo..."

mkdir -p "$SYSTEM_CONFIG_DIR" "$SYSTEMD_USER_CONFIG_DIR"

if [[ -f /etc/udev/rules.d/99-uinput.rules ]]; then
  cp -f /etc/udev/rules.d/99-uinput.rules "$SYSTEM_CONFIG_DIR/99-uinput.rules"
else
  warn "No existe /etc/udev/rules.d/99-uinput.rules"
fi

if [[ -f /etc/modules-load.d/uinput.conf ]]; then
  cp -f /etc/modules-load.d/uinput.conf "$SYSTEM_CONFIG_DIR/uinput.conf"
else
  warn "No existe /etc/modules-load.d/uinput.conf"
fi

if [[ -f /etc/lightdm/lightdm.conf ]]; then
  cp -f /etc/lightdm/lightdm.conf "$SYSTEM_CONFIG_DIR/lightdm.conf"
else
  warn "No existe /etc/lightdm/lightdm.conf"
fi

if [[ -f /etc/systemd/system/dashboard-stack.service ]]; then
  cp -f /etc/systemd/system/dashboard-stack.service "$SYSTEM_CONFIG_DIR/dashboard-stack.service"
else
  warn "No existe /etc/systemd/system/dashboard-stack.service"
fi

if [[ -f "$HOME/.config/systemd/user/sunshine.service" ]]; then
  cp -f "$HOME/.config/systemd/user/sunshine.service" "$SYSTEMD_USER_CONFIG_DIR/sunshine.service"
else
  warn "No existe $HOME/.config/systemd/user/sunshine.service"
fi

say "Hecho. Revisa git diff y commitea."
