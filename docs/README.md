# 📚 Documentación del Servidor

Índice completo de toda la documentación disponible.

## 🚀 Inicio Rápido

- **[Workflow de Mantenimiento](guides/workflow.md)** - Cómo mantener este repositorio actualizado

## 📖 Guías de Setup

- **[Sunshine Streaming](setup/sunshine-setup.md)** - Configuración del servidor de streaming
- **[Docker Setup](setup/docker-setup.md)** - Gestión de contenedores individuales
- **[Docker Compose](setup/docker-compose-setup.md)** - Stack completo con compose

## 🏗️ Arquitectura

- **[Overview del Sistema](architecture/overview.md)** - Diseño general y componentes

## 🔧 Operaciones

- **[Troubleshooting](operations/troubleshooting.md)** - Solución de problemas comunes

## 📝 Guías

- **[Workflow](guides/workflow.md)** - Rutinas de mantenimiento y mejores prácticas

## 🎯 Por Tarea

### Quiero actualizar el repositorio con cambios del servidor
→ Lee [Workflow de Mantenimiento](guides/workflow.md)

### Tengo problemas con Sunshine
→ Lee [Troubleshooting](operations/troubleshooting.md) sección Sunshine

### Quiero añadir un contenedor Docker
→ Lee [Docker Compose Setup](setup/docker-compose-setup.md)

### Necesito entender cómo está organizado el servidor
→ Lee [Architecture Overview](architecture/overview.md)

### Voy a reinstalar el servidor desde cero
→ Sigue las guías de Setup en orden

## 📊 Estado Actual

- **Sunshine**: paquete instalado y binario en `/usr/bin/sunshine`
- **Dashboard**: configuración pública versionada en `docker-compose.yml` y `configs/homepage/`
- **Servicios base detectados**: Apache2, Samba, SSH, Tailscale y LightDM
- **Systemd**: inventario público en `configs/system/systemd-*.txt`

## 🔄 Última actualización

Ver archivo `.last-update` en la raíz del repositorio.
