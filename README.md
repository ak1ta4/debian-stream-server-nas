# 🖥️ Debian Stream Server + NAS

Documentación completa y configuraciones de mi servidor Debian 13 (Trixie) con streaming, dashboard y almacenamiento NAS.

[![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Sunshine](https://img.shields.io/badge/Sunshine-2025.924-00C853)](https://github.com/LizardByte/Sunshine)

## 📊 Estado del Servidor

- **Sistema**: Debian GNU/Linux 13 (Trixie)
- **Kernel**: 6.12.63+deb13-amd64
- **Hardware**: Ryzen 5 5600H (6C/12T)
- **RAM**: 15GB DDR4
- **GPUs**: NVIDIA RTX 3050 + AMD Radeon Vega
- **Almacenamiento**: 476GB NVMe + 223GB SSD + 111GB SSD

## 🎯 Servicios

- **Streaming**: Sunshine 2025.924
- **Dashboard**: Homepage (puerto 3000)
- **Monitoring**: Glances (puerto 61208)
- **Docker**: Portainer (puerto 9000)
- **SSH**: Puerto 22

## 📁 Estructura

- `docs/` - Documentación completa
  - `setup/` - Guías de instalación
  - `guides/` - Tutoriales y workflows
  - `operations/` - Troubleshooting
  - `architecture/` - Diseño del sistema
- `configs/` - Configuraciones del servidor
- `scripts/` - Scripts de automatización
- `hardware/` - Información de hardware

## 🚀 Uso Rápido

### Actualizar configuraciones después de cambios
```bash
cd ~/debian-server-docs
./scripts/backup/update-configs.sh
git add .
git commit -m "Descripción del cambio"
git push
```

### Ver documentación
```bash
cat docs/guides/workflow.md        # Workflow completo
cat docs/setup/sunshine-setup.md   # Setup de Sunshine
cat docs/setup/docker-setup.md     # Setup de Docker
```

## 📖 Documentación Principal

1. **[Workflow de Mantenimiento](docs/guides/workflow.md)** ⭐ - Cómo mantener este repo actualizado
2. **[Arquitectura](docs/architecture/overview.md)** - Diseño del sistema
3. **[Sunshine Setup](docs/setup/sunshine-setup.md)** - Configuración de streaming
4. **[Docker Setup](docs/setup/docker-setup.md)** - Gestión de contenedores
5. **[Troubleshooting](docs/operations/troubleshooting.md)** - Solución de problemas

## 🌐 Acceso

- **Homepage**: http://192.168.1.55:3000
- **Glances**: http://192.168.1.55:61208
- **Portainer**: http://192.168.1.55:9000
- **SSH**: `ssh ak1t4@192.168.1.55`

## 🔧 Scripts Disponibles

- `scripts/backup/update-configs.sh` - Actualiza todas las configuraciones
- `scripts/monitoring/system-inventory.sh` - Genera snapshot del sistema
- `scripts/custom/apply.sh` - Script personalizado
- `scripts/custom/collect.sh` - Script personalizado
