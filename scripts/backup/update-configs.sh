#!/bin/bash
# Script para actualizar todas las configuraciones del servidor

REPO_DIR="$HOME/debian-server-docs"
cd "$REPO_DIR" || exit 1

echo "🔄 Actualizando configuraciones..."

# Docker Compose
echo "  - docker-compose.yml"
cp /srv/docker/dashboard/docker-compose.yml ./ 2>/dev/null || echo "    ⚠️  docker-compose.yml no encontrado en /srv/docker/dashboard"

# Sunshine
echo "  - Sunshine"
cp ~/.config/sunshine/apps.json configs/sunshine/
cp ~/.config/sunshine/sunshine.conf configs/sunshine/
cp ~/.config/sunshine/sunshine_state.json configs/sunshine/

# Homepage config
echo "  - Homepage"
cp -r /srv/docker/dashboard/stack/config/* configs/homepage/ 2>/dev/null
rm -rf configs/homepage/logs 2>/dev/null

# Docker containers
echo "  - Docker containers"
docker ps --format "{{.Names}}" | while read container; do
  mkdir -p "configs/docker/$container"
  docker inspect $container > "configs/docker/$container/inspect.json"
done

# Sistema
echo "  - Sistema"
sudo cp /etc/ssh/sshd_config configs/system/sshd_config 2>/dev/null
systemctl list-units --type=service --state=running > configs/system/systemd-running.txt

# Autostart
echo "  - Autostart XFCE"
cp ~/.config/autostart/*.desktop configs/xfce/autostart/ 2>/dev/null

# Fecha de actualización
date > .last-update

echo "✅ Configuraciones actualizadas: $(date)"
echo "💡 No olvides hacer commit: git add . && git commit -m 'Update configs' && git push"
