#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

say() { printf "\n\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\n\033[1;33m[WARN]\033[0m %s\n" "$*"; }
die() { printf "\n\033[1;31m[ERR]\033[0m %s\n" "$*"; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Falta comando: $1"; }

need_root_for() {
  if [[ $EUID -ne 0 ]]; then
    die "Este paso requiere root. Ejecuta: sudo $0"
  fi
}

# --- Prechecks ---
need_cmd cp
need_cmd id
need_cmd grep
need_cmd systemctl
need_cmd udevadm

USER_NAME="${SUDO_USER:-$(id -un)}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"

[[ -n "$HOME_DIR" ]] || die "No pude determinar HOME de $USER_NAME"

say "Repo: $REPO_ROOT"
say "Usuario objetivo: $USER_NAME"
say "Home usuario: $HOME_DIR"

# --- 1) uinput module load (persist) ---
say "Instalando config de carga automática de uinput..."
need_root_for
install -d /etc/modules-load.d
cp -f "$REPO_ROOT/configs/modules-load/uinput.conf" /etc/modules-load.d/uinput.conf
chmod 644 /etc/modules-load.d/uinput.conf

say "Cargando módulo uinput ahora (si no está ya)..."
modprobe uinput || true

# --- 2) udev rule for /dev/uinput ---
say "Instalando regla udev para /dev/uinput..."
install -d /etc/udev/rules.d
cp -f "$REPO_ROOT/configs/udev/99-uinput.rules" /etc/udev/rules.d/99-uinput.rules
chmod 644 /etc/udev/rules.d/99-uinput.rules

say "Recargando reglas udev..."
udevadm control --reload-rules
udevadm trigger

# --- 3) Ensure user is in input group ---
say "Añadiendo usuario '$USER_NAME' al grupo 'input' (si falta)..."
if id -nG "$USER_NAME" | tr ' ' '\n' | grep -qx input; then
  say "OK: '$USER_NAME' ya está en el grupo input."
else
  gpasswd -a "$USER_NAME" input
  warn "Grupo input añadido. Necesitas cerrar sesión y volver a entrar (o reiniciar) para que se aplique."
fi

# --- 4) LightDM autologin config (optional but requested) ---
LIGHTDM_CFG_SRC="$REPO_ROOT/configs/lightdm/lightdm.conf"
LIGHTDM_CFG_DST="/etc/lightdm/lightdm.conf"

if [[ -f "$LIGHTDM_CFG_SRC" ]]; then
  say "Instalando configuración LightDM autologin..."
  cp -f "$LIGHTDM_CFG_SRC" "$LIGHTDM_CFG_DST"
  chmod 644 "$LIGHTDM_CFG_DST"

  # Aviso si el archivo contiene un usuario distinto
  if grep -q '^autologin-user=' "$LIGHTDM_CFG_DST"; then
    CFG_USER="$(grep '^autologin-user=' "$LIGHTDM_CFG_DST" | head -n1 | cut -d= -f2)"
    if [[ "$CFG_USER" != "$USER_NAME" ]]; then
      warn "LightDM autologin-user está en '$CFG_USER' pero tu usuario actual es '$USER_NAME'."
      warn "Edita configs/lightdm/lightdm.conf si quieres que autologuee '$USER_NAME'."
    fi
  fi
else
  warn "No existe $LIGHTDM_CFG_SRC, salto autologin."
fi

# --- 5) Sunshine autostart (systemd user) ---
say "Configurando autostart de Sunshine con systemd --user..."

SUNSHINE_BIN="$(command -v sunshine || true)"
if [[ -z "$SUNSHINE_BIN" ]]; then
  warn "No encuentro el binario 'sunshine' en PATH. Instálalo y vuelve a ejecutar este script."
else
  say "Sunshine encontrado en: $SUNSHINE_BIN"
fi

SYSTEMD_USER_DIR="$HOME_DIR/.config/systemd/user"
SERVICE_SRC="$REPO_ROOT/configs/systemd-user/sunshine.service"
SERVICE_DST="$SYSTEMD_USER_DIR/sunshine.service"

install -d -m 755 "$SYSTEMD_USER_DIR"
cp -f "$SERVICE_SRC" "$SERVICE_DST"
chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config"

# Si el service hardcodea /usr/bin/sunshine y tu binario está en otro sitio, lo parcheamos
if [[ -n "$SUNSHINE_BIN" ]]; then
  if grep -q '^ExecStart=' "$SERVICE_DST"; then
    CURRENT_EXEC="$(grep '^ExecStart=' "$SERVICE_DST" | head -n1 | cut -d= -f2-)"
    if [[ "$CURRENT_EXEC" != "$SUNSHINE_BIN" ]]; then
      say "Actualizando ExecStart de Sunshine service: $CURRENT_EXEC -> $SUNSHINE_BIN"
      # sed con delimitador seguro
      sed -i "s|^ExecStart=.*$|ExecStart=$SUNSHINE_BIN|" "$SERVICE_DST"
    fi
  fi
fi

# Habilitar linger para que el user service pueda arrancar sin login manual
say "Activando linger para '$USER_NAME'..."
loginctl enable-linger "$USER_NAME" || warn "No pude activar linger (¿systemd-logind?)."

# Habilitar y arrancar servicio de usuario
say "Habilitando/arrancando sunshine.service para '$USER_NAME'..."
sudo -u "$USER_NAME" systemctl --user daemon-reload
sudo -u "$USER_NAME" systemctl --user enable --now sunshine.service || warn "No pude iniciar sunshine.service. Revisa logs."

say "Estado sunshine.service:"
sudo -u "$USER_NAME" systemctl --user --no-pager status sunshine.service || true

# --- 6) Final checks ---
say "Checks finales rápidos:"
echo "- XDG_SESSION_TYPE (si estás en GUI): ${XDG_SESSION_TYPE:-"(no disponible en esta shell)"}"
echo "- /dev/uinput:"
ls -l /dev/uinput || true
echo "- Grupos de $USER_NAME:"
id -nG "$USER_NAME" || true

warn "Si acabas de añadir grupo input: haz logout/login o reinicia."
say "Listo."
