#!/bin/bash
# Genera un snapshot completo del estado del sistema

REPO_DIR="$HOME/debian-server-docs"
OUTPUT_DIR="$REPO_DIR/hardware"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR/snapshots/$DATE"

echo "📸 Generando snapshot del sistema..."

# Hardware
lscpu > "$OUTPUT_DIR/snapshots/$DATE/cpu.txt"
free -h > "$OUTPUT_DIR/snapshots/$DATE/memory.txt"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL > "$OUTPUT_DIR/snapshots/$DATE/disks.txt"
lspci > "$OUTPUT_DIR/snapshots/$DATE/pci.txt"
lsusb > "$OUTPUT_DIR/snapshots/$DATE/usb.txt"

# Red
ip addr > "$OUTPUT_DIR/snapshots/$DATE/network.txt"
ip route >> "$OUTPUT_DIR/snapshots/$DATE/network.txt"

# Docker
docker ps -a > "$OUTPUT_DIR/snapshots/$DATE/docker-containers.txt"
docker images > "$OUTPUT_DIR/snapshots/$DATE/docker-images.txt"

# Servicios
systemctl list-units --type=service --state=running > "$OUTPUT_DIR/snapshots/$DATE/services.txt"

# GPU
nvidia-smi > "$OUTPUT_DIR/snapshots/$DATE/gpu.txt" 2>/dev/null || echo "AMD GPU" > "$OUTPUT_DIR/snapshots/$DATE/gpu.txt"

echo "✅ Snapshot guardado en: $OUTPUT_DIR/snapshots/$DATE"
