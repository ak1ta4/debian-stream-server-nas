# 🖥️ Debian Stream Server + NAS

Documentación completa y configuraciones de mi servidor Debian 13 (Trixie) con streaming, dashboard y almacenamiento NAS.

[![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Sunshine](https://img.shields.io/badge/Sunshine-2025.924-00C853)](https://github.com/LizardByte/Sunshine)

## 📊 Estado del Servidor

- **Hostname**: `ak1t4-server`
- **Sistema**: Debian GNU/Linux 13.3 (Trixie)
- **Kernel**: 6.12.63+deb13-amd64
- **Hardware**: Ryzen 5 5600H (6C/12T)
- **RAM**: 16GB DDR4
- **GPUs**: NVIDIA RTX 3050 + AMD Radeon Vega
- **Almacenamiento detectado en esta actualización**: NVMe 476.9GB montado en `/`

## 🎯 Servicios

- **Streaming**: Sunshine 2025.924
- **Dashboard versionado**: Homepage + Glances
- **Portainer**: opcional en la plantilla pública de compose
- **Sistema**: SSH, Samba, Tailscale, Apache2 y LightDM
- **SSH**: Puerto 22

## 🐳 Docker Compose

Todos los servicios del dashboard se gestionan con docker-compose:
```bash
docker-compose up -d      # Iniciar servicios
docker-compose logs -f    # Ver logs
docker-compose ps         # Estado
```

## 📁 Estructura

- `docker-compose.yml` - Definición de servicios
- `docs/` - Documentación completa
  - `setup/` - Guías de instalación
  - `guides/` - Tutoriales y workflows
  - `operations/` - Troubleshooting
  - `architecture/` - Diseño del sistema
- `configs/` - Configuraciones del servidor
  - `homepage/` - Config de Homepage dashboard
  - `sunshine/` - Config de streaming
  - `docker/` - Inspects de contenedores
  - `system/` - systemd, udev, LightDM y modules-load
  - `systemd-user/` - Servicios de usuario
- `scripts/` - Scripts de automatización
- `hardware/` - Información de hardware

## 🚀 Inicio Rápido

### Levantar el stack completo
```bash
cd ~/debian-stream-server-nas
# Opcional: crea .env desde .env.example si quieres exponer servicios en LAN
docker-compose up -d
```

### Actualizar configuraciones después de cambios
```bash
./scripts/backup/update-configs.sh
git add .
git commit -m "Update configs"
git push
```

## 📖 Documentación Principal

1. **[Workflow de Mantenimiento](docs/guides/workflow.md)** ⭐ - Cómo mantener este repo
2. **[Docker Compose Setup](docs/setup/docker-compose-setup.md)** - Gestión de servicios
3. **[Arquitectura](docs/architecture/overview.md)** - Diseño del sistema
4. **[Sunshine Setup](docs/setup/sunshine-setup.md)** - Streaming
5. **[Troubleshooting](docs/operations/troubleshooting.md)** - Solución de problemas

## 🌐 Acceso

IPs de ejemplo del repo público. Los valores reales deben vivir fuera de este repositorio.

- **Homepage**: http://192.168.1.100:3000
- **Glances**: http://192.168.1.100:61208
- **Portainer**: http://192.168.1.100:9000
- **SSH**: `ssh ak1t4@192.168.1.100`

## 🔧 Scripts Disponibles

- `scripts/backup/update-configs.sh` - Actualiza configuraciones
- `scripts/monitoring/system-inventory.sh` - Snapshot del sistema
- `scripts/custom/apply.sh` - Script personalizado
- `scripts/custom/collect.sh` - Script personalizado
