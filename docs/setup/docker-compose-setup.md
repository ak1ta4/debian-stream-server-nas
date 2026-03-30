# Docker Compose Setup

## Estructura actual

- Plantilla pública versionada: `docker-compose.yml` en la raíz del repo.
- Stack desplegado actualmente en el servidor: `/srv/docker/dashboard/stack/compose.yaml`.
- Unidad systemd asociada: `dashboard-stack.service`.

## Servicios

### Homepage
- **Puerto**: 3000
- **Config en plantilla pública**: `./configs/homepage` → `/app/config`
- **Config desplegada en servidor**: `/srv/docker/dashboard/stack/config` → `/app/config`
- **Variables**: `HOMEPAGE_ALLOWED_HOSTS` se configura desde `.env`

### Glances
- **Puerto**: 61208
- **Acceso**: Sistema host (`/proc`, `/sys`, `/etc/os-release`)
- **Modo**: Web (`-w`)

### Portainer
- **Puertos**: 9000 y 9443
- **Persistencia**: volumen `dashboard_portainer_data`
- **Estado**: forma parte tanto de la plantilla pública como del stack desplegado en `/srv`

## Uso

Los puertos quedan enlazados a `SERVER_BIND_IP`. Por defecto el repo solo publica en `127.0.0.1`; si quieres acceso LAN, ajusta `.env`.

### Iniciar todos los servicios de la plantilla pública
```bash
docker compose up -d
```

### Ver logs
```bash
docker compose logs -f
docker compose logs -f homepage
```

### Parar servicios
```bash
docker compose down
```

### Reiniciar un servicio
```bash
docker compose restart homepage
```

### Actualizar imágenes
```bash
docker compose pull
docker compose up -d
```

### Ver estado
```bash
docker compose ps
```

## Runtime actual en el servidor

El despliegue versionado fuera del repo se gestiona con:

```bash
sudo systemctl status dashboard-stack.service
sudo systemctl restart dashboard-stack.service
```

También existe un compose legacy en `/srv/docker/dashboard/docker-compose.yml`; debe mantenerse alineado solo como referencia/compatibilidad.

## Configuración de Homepage

Los archivos públicos versionados están en:

```bash
configs/homepage/
```

La copia desplegada del servidor vive en:

```bash
/srv/docker/dashboard/stack/config/
```

## Red

Todos los servicios comparten la red `dashboard` (bridge) en la plantilla pública.

## Volúmenes

- `portainer_data`: alias del volumen persistente `dashboard_portainer_data`.

## Nota operativa

Durante la actualización del `2026-03-30`, el daemon Docker no estaba accesible, así que los `inspect.json` del repo deben considerarse último snapshot conocido, no estado en vivo.
