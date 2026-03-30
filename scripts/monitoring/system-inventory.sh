#!/usr/bin/env bash
set -euo pipefail

# Genera un snapshot completo del estado del sistema.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$REPO_DIR/hardware"
DATE="$(date +%Y%m%d_%H%M%S)"
SNAPSHOT_DIR="$OUTPUT_DIR/snapshots/$DATE"

mkdir -p "$SNAPSHOT_DIR"

echo "📸 Generando snapshot del sistema..."

write_dual() {
  local current_file="$1"
  local snapshot_file="$2"
  shift 2

  "$@" | tee "$current_file" > "$snapshot_file"
}

write_cmd_or_note() {
  local current_file="$1"
  local snapshot_file="$2"
  shift 2

  if "$@" > "$current_file" 2>/dev/null; then
    cp -f "$current_file" "$snapshot_file"
  else
    printf "Comando no disponible o sin salida.\n" > "$current_file"
    cp -f "$current_file" "$snapshot_file"
  fi
}

# Hardware canónico + snapshot
write_dual "$OUTPUT_DIR/cpuinfo.txt" "$SNAPSHOT_DIR/cpu.txt" lscpu
write_dual "$OUTPUT_DIR/memory.txt" "$SNAPSHOT_DIR/memory.txt" free -h
write_dual "$OUTPUT_DIR/disks.txt" "$SNAPSHOT_DIR/disks.txt" lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL
write_dual "$OUTPUT_DIR/lspci-verbose.txt" "$SNAPSHOT_DIR/pci.txt" lspci -nn
write_dual "$OUTPUT_DIR/lsusb.txt" "$SNAPSHOT_DIR/usb.txt" lsusb
write_cmd_or_note "$OUTPUT_DIR/gpu-type.txt" "$SNAPSHOT_DIR/gpu-type.txt" sh -c "lspci | grep -iE 'vga|3d|display'"
write_cmd_or_note "$OUTPUT_DIR/installed-packages.txt" "$SNAPSHOT_DIR/packages.txt" dpkg -l

if command -v lshw >/dev/null 2>&1; then
  if lshw -short > "$OUTPUT_DIR/lshw-short.txt" 2>/dev/null; then
    cp -f "$OUTPUT_DIR/lshw-short.txt" "$SNAPSHOT_DIR/lshw-short.txt"
  else
    printf "lshw no disponible sin privilegios suficientes.\n" > "$OUTPUT_DIR/lshw-short.txt"
    cp -f "$OUTPUT_DIR/lshw-short.txt" "$SNAPSHOT_DIR/lshw-short.txt"
  fi
else
  printf "lshw no instalado.\n" > "$OUTPUT_DIR/lshw-short.txt"
  cp -f "$OUTPUT_DIR/lshw-short.txt" "$SNAPSHOT_DIR/lshw-short.txt"
fi

# Red
ip addr > "$SNAPSHOT_DIR/network.txt"
ip route >> "$SNAPSHOT_DIR/network.txt"

# Docker
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker ps -a > "$SNAPSHOT_DIR/docker-containers.txt"
  docker images > "$SNAPSHOT_DIR/docker-images.txt"
else
  printf "Docker no disponible o daemon inactivo.\n" > "$SNAPSHOT_DIR/docker-containers.txt"
  printf "Docker no disponible o daemon inactivo.\n" > "$SNAPSHOT_DIR/docker-images.txt"
fi

# Servicios
systemctl list-units --type=service --state=running > "$SNAPSHOT_DIR/services.txt"

# GPU
if nvidia-smi > "$OUTPUT_DIR/nvidia-gpu.txt" 2>/dev/null; then
  cp -f "$OUTPUT_DIR/nvidia-gpu.txt" "$SNAPSHOT_DIR/gpu.txt"
else
  echo "nvidia-smi no disponible" > "$OUTPUT_DIR/nvidia-gpu.txt"
  cp -f "$OUTPUT_DIR/nvidia-gpu.txt" "$SNAPSHOT_DIR/gpu.txt"
fi

echo "✅ Snapshot guardado en: $SNAPSHOT_DIR"
