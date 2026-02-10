# 🖥️ Debian Server Documentation

Documentación completa de mi servidor Debian 13 (Trixie) con streaming, dashboard y NAS.

## 📊 Estado del Servidor

- **Sistema**: Debian GNU/Linux 13 (Trixie)
- **Kernel**: 6.12.63+deb13-amd64
- **Hardware**: Ryzen 5 5600H (6C/12T)
- **GPUs**: AMD Radeon Vega + NVIDIA RTX 3050 
- **RAM**: 15GB
- **Almacenamiento**: 476GB NVMe + 223GB SSD + 111GB SSD

## 🎯 Servicios Activos

### Docker Containers
- **Homepage** - Puerto 3000
- **Glances** - Puerto 61208
- **Portainer** - Puerto 9000

### Sunshine Streaming
- **Versión**: 2025.924.154138
- **GPU**: NVIDIA RTX 3050 + AMD Radeon Vega

## 📁 Estructura del Repositorio

- `docs/` - Documentación detallada
- `configs/` - Configuraciones del servidor
- `scripts/` - Scripts de automatización
- `hardware/` - Información de hardware

## 🚀 Inicio Rápido

### Actualizar configuraciones
```bash
./scripts/backup/update-configs.sh
```

### Ver documentación
```bash
ls docs/setup/
```

## 🌐 Acceso

- Homepage: http://192.168.1.55:3000
- Glances: http://192.168.1.55:61208
- Portainer: http://192.168.1.55:9000
- SSH: ssh ak1t4@192.168.1.55
