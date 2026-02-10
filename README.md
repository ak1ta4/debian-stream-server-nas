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

- `docs/` - Documentación
- `configs/` - Configuraciones del servidor
- `scripts/` - Scripts de automatización
- `hardware/` - Info de hardware

## 🚀 Uso

Actualizar configuraciones:
```bash
./scripts/backup/update-configs.sh
```

Ver documentación completa en `docs/`

## 🌐 Acceso

- Homepage: http://192.168.1.55:3000
- Glances: http://192.168.1.55:61208
- Portainer: http://192.168.1.55:9000
- SSH: ssh ak1t4@192.168.1.55
