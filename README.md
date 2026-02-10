# 🖥️ Debian Stream Server + NAS

Documentación completa y configuraciones de mi servidor Debian 13 (Trixie) con streaming, dashboard y almacenamiento NAS.

[![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Sunshine](https://img.shields.io/badge/Sunshine-2025.924-00C853)](https://github.com/LizardByte/Sunshine)

---

## 📊 Estado del Servidor

| Componente | Especificación |
|-----------|----------------|
| **Sistema** | Debian GNU/Linux 13 (Trixie) |
| **Kernel** | 6.12.63+deb13-amd64 |
| **Hardware** | HP Victus 16 - Ryzen 5 5600H (6C/12T) |
| **RAM** | 15GB DDR4 |
| **GPU Principal** | NVIDIA GeForce RTX 3050 Mobile |
| **GPU Integrada** | AMD Radeon Vega |
| **Almacenamiento** | 476GB NVMe + 223GB SSD + 111GB SSD |
| **Red** | Ethernet Gigabit (192.168.1.55) |

---

## 🎯 Funcionalidades

### ✅ Implementado

- **🎮 Streaming**: Sunshine 2025.924 con encoding por GPU NVIDIA
- **📊 Dashboard**: Homepage + Glances + Portainer
- **🐳 Docker**: Gestión de contenedores
- **🔐 SSH**: Acceso remoto seguro
- **⚡ Autostart**: Servicios automáticos con XFCE
- **🖱️ Input**: uinput configurado para control remoto

### 🚧 Próximamente

- **💾 NAS**: Samba/NFS shares en discos adicionales
- **☁️ Nextcloud**: Almacenamiento en la nube privado
- **🔄 Backup**: Sistema automático de respaldos
- **📈 Monitoring**: Prometheus + Grafana

---

## 📁 Estructura del Repositorio
```
debian-server-docs/
├── docs/                      # 📖 Documentación detallada
│   ├── setup/                # Guías de instalación
│   ├── architecture/         # Diseño del sistema
│   ├── operations/           # Troubleshooting
│   └── guides/               # Tutoriales
├── configs/                  # ⚙️ Configuraciones
│   ├── sunshine/            # Streaming
│   ├── docker/              # Contenedores
│   ├── system/              # SSH, systemd, udev
│   ├── network/             # Red
│   └── xfce/                # Desktop
├── scripts/                 # 🔧 Automatización
│   ├── backup/             # Update configs
│   ├── monitoring/         # System inventory
│   └── custom/             # Scripts personalizados
├── hardware/               # 🖥️ Info de hardware
└── assets/                # 🎨 Recursos
```

---

## 🚀 Inicio Rápido

### Ver documentación
```bash
# Arquitectura del sistema
cat docs/architecture/overview.md

# Instalación de Sunshine
cat docs/setup/sunshine-setup.md

# Docker setup
cat docs/setup/docker-setup.md
```

### Actualizar configuraciones
```bash
# Ejecutar script de backup
./scripts/backup/update-configs.sh

# Commit y push
git add .
git commit -m "Update configs"
git push
```

### Generar snapshot del sistema
```bash
./scripts/monitoring/system-inventory.sh
```

---

## 🌐 Servicios y Puertos

| Servicio | Puerto | URL | Estado |
|----------|--------|-----|--------|
| **Homepage** | 3000 | http://192.168.1.55:3000 | ✅ Running |
| **Glances** | 61208 | http://192.168.1.55:61208 | ✅ Running |
| **Portainer** | 9000 | http://192.168.1.55:9000 | ✅ Running |
| **Sunshine** | 47989 | - | ✅ Running |
| **SSH** | 22 | ssh ak1t4@192.168.1.55 | ✅ Running |

---

## 📖 Documentación

1. **[Arquitectura](docs/architecture/overview.md)** - Diseño y componentes del sistema
2. **[Sunshine Setup](docs/setup/sunshine-setup.md)** - Configuración de streaming
3. **[Docker Setup](docs/setup/docker-setup.md)** - Gestión de contenedores
4. **[Troubleshooting](docs/operations/troubleshooting.md)** - Solución de problemas

---

## 🔧 Contenedores Docker

### Homepage
- **Imagen**: `ghcr.io/gethomepage/homepage:latest`
- **Función**: Dashboard central del servidor
- **Estado**: Healthy ✅

### Glances
- **Imagen**: `nicolargo/glances:latest`
- **Función**: Monitorización en tiempo real
- **Estado**: Running ✅

### Portainer
- **Imagen**: `portainer/portainer-ce:latest`
- **Función**: Gestión visual de Docker
- **Estado**: Running ✅

---

## 📝 Mantenimiento

### Workflow recomendado

1. **Hacer cambios** en el servidor
2. **Ejecutar** `./scripts/backup/update-configs.sh`
3. **Revisar** cambios con `git status`
4. **Commit** con `git commit -m "Descripción del cambio"`
5. **Push** con `git push`

### Backup mensual
```bash
# Generar snapshot completo
./scripts/monitoring/system-inventory.sh

# Commit snapshot
git add hardware/snapshots/
git commit -m "Monthly snapshot $(date +%Y-%m)"
git push
```

---

## 🛠️ Comandos Útiles

### Docker
```bash
docker ps                    # Ver contenedores activos
docker logs homepage         # Ver logs
docker restart glances       # Reiniciar contenedor
```

### Sunshine
```bash
ps aux | grep sunshine       # Verificar proceso
tail -f ~/.config/sunshine/sunshine.log  # Ver logs
```

### Sistema
```bash
htop                        # Monitor de recursos
df -h                       # Espacio en disco
systemctl status ssh        # Estado de SSH
```

---

## 📜 Licencia

Documentación personal - Libre para uso como referencia.

---

**Última actualización**: Febrero 2026  
**Repositorio**: https://github.com/ak1ta4/debian-stream-server-nas
