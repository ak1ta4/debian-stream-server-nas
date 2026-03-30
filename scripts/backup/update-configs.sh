#!/usr/bin/env bash
set -euo pipefail

# Script para actualizar el repo público con configuraciones no sensibles.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_DIR" || exit 1

warn() { printf "    [WARN] %s\n" "$*"; }
PUBLIC_SERVER_IP="${PUBLIC_SERVER_IP:-192.168.1.100}"

copy_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -e "$src" ]]; then
    cp -f "$src" "$dst"
  else
    warn "No encontrado: $src"
  fi
}

detect_local_ipv4() {
  ip route get 1.1.1.1 2>/dev/null | awk '
    {
      for (i = 1; i <= NF; i++) {
        if ($i == "src" && (i + 1) <= NF) {
          print $(i + 1)
          exit
        }
      }
    }
  '
}

sanitize_text_tree() {
  local dir="$1"
  local detected_ip="$2"

  [[ -d "$dir" ]] || return 0
  [[ -n "$detected_ip" ]] || return 0

  find "$dir" -type f \
    \( -name '*.yaml' -o -name '*.yml' -o -name '*.js' -o -name '*.json' -o -name '*.txt' \) \
    -print0 | while IFS= read -r -d '' file; do
      sed -i "s#${detected_ip}#${PUBLIC_SERVER_IP}#g" "$file"
    done
}

LOCAL_SERVER_IP="$(detect_local_ipv4 || true)"

echo "🔄 Actualizando configuraciones..."

mkdir -p \
  configs/docker \
  configs/homepage \
  configs/sunshine \
  configs/system \
  configs/xfce/autostart

# Docker Compose
echo "  - docker-compose.yml"
warn "La plantilla pública docker-compose.yml se mantiene en el repo y no se sobrescribe desde /srv."

# Sunshine
echo "  - Sunshine"
copy_if_exists "$HOME/.config/sunshine/apps.json" configs/sunshine/apps.json
if command -v dpkg-query >/dev/null 2>&1; then
  {
    dpkg-query -W -f='${db:Status-Abbrev} ${Package} ${Version} ${Architecture} ${binary:Summary}\n' sunshine 2>/dev/null || true
    command -v sunshine 2>/dev/null || true
  } > configs/sunshine/sunshine-package-info.txt
fi
if ps -C sunshine -o user=,pid=,etime=,cmd= >/dev/null 2>&1; then
  ps -C sunshine -o user=,pid=,etime=,cmd= > configs/sunshine/sunshine-process.txt
else
  printf "sunshine no activo\n" > configs/sunshine/sunshine-process.txt
fi
warn "Se omiten sunshine.conf y sunshine_state.json del repo público; guárdalos en config-privado."

# Homepage config
echo "  - Homepage"
if [[ -d /srv/docker/dashboard/stack/config ]]; then
  cp -r /srv/docker/dashboard/stack/config/. configs/homepage/
  sanitize_text_tree "configs/homepage" "$LOCAL_SERVER_IP"
  rm -rf configs/homepage/logs 2>/dev/null || true
else
  warn "No encontrada la config de Homepage en /srv/docker/dashboard/stack/config"
fi

# Docker containers
echo "  - Docker containers"
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    for container in homepage glances portainer; do
      mkdir -p "configs/docker/$container"
      docker inspect "$container" > "configs/docker/$container/inspect.json" || warn "No se pudo inspeccionar $container"
    done
    sanitize_text_tree "configs/docker" "$LOCAL_SERVER_IP"
  else
    warn "docker está instalado pero el daemon no responde; no se actualizan inspect.json"
  fi
else
  warn "docker no está disponible; no se actualizan inspect.json"
fi

# Sistema
echo "  - Sistema"
if command -v systemctl >/dev/null 2>&1; then
  systemctl list-units --type=service --state=running > configs/system/systemd-running.txt
  systemctl list-unit-files --type=service --state=enabled > configs/system/systemd-enabled.txt
else
  warn "systemctl no está disponible; no se actualiza el inventario de servicios"
fi
warn "Se omiten sshd_config y snapshots de red del repo público; mantenlos en config-privado."

# Autostart
echo "  - Autostart XFCE"
if compgen -G "$HOME/.config/autostart/*.desktop" >/dev/null; then
  cp "$HOME"/.config/autostart/*.desktop configs/xfce/autostart/
else
  warn "No hay archivos .desktop en $HOME/.config/autostart"
fi

# Fecha de actualización
date > .last-update

echo "✅ Configuraciones actualizadas: $(date)"
echo "💡 Revisa git diff antes de commitear."
