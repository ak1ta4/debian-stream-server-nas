# Docker Compose Setup

## Estructura

Todos los servicios del dashboard están definidos en `docker-compose.yml` en la raíz del proyecto.

## Servicios

### Homepage
- **Puerto**: 3000
- **Config**: `/srv/docker/dashboard/stack/config` → `/app/config`
- **Variables**: HOMEPAGE_ALLOWED_HOSTS configurado para acceso local

### Glances
- **Puerto**: 61208
- **Acceso**: Sistema host (proc, sys, os-release)
- **Modo**: Web (-w)

### Portainer
- **Puertos**: 9000 (HTTP), 9443 (HTTPS)
- **Volumen**: portainer_data (persistente)
- **Docker socket**: Montado para gestión

## Uso

### Iniciar todos los servicios
```bash
docker-compose up -d
```

### Ver logs
```bash
docker-compose logs -f
docker-compose logs -f homepage
```

### Parar servicios
```bash
docker-compose down
```

### Reiniciar un servicio
```bash
docker-compose restart homepage
```

### Actualizar imágenes
```bash
docker-compose pull
docker-compose up -d
```

### Ver estado
```bash
docker-compose ps
```

## Configuración de Homepage

Los archivos de configuración están en:
```
/srv/docker/dashboard/stack/config/
├── bookmarks.yaml
├── docker.yaml
├── services.yaml
├── settings.yaml
└── widgets.yaml
```

Copia de respaldo en: `configs/homepage/`

## Red

Todos los servicios comparten la red `dashboard` (bridge).

## Volúmenes

- `portainer_data`: Datos persistentes de Portainer

## Migración desde contenedores individuales

Si ya tienes los contenedores corriendo:

1. Parar contenedores actuales:
```bash
docker stop homepage glances portainer
docker rm homepage glances portainer
```

2. Iniciar con docker-compose:
```bash
docker-compose up -d
```

Los datos de Portainer se preservan porque usa el mismo volumen.
