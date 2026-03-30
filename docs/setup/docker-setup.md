# Docker Setup

## Estado versionado

### Homepage
- Imagen: `${HOMEPAGE_IMAGE}` (por defecto `ghcr.io/gethomepage/homepage:v1.10.1`)
- Puerto: 3000
- Acceso: http://192.168.1.100:3000

### Glances
- Imagen: `${GLANCES_IMAGE}` (define un tag o digest en `.env`)
- Puerto: 61208
- Acceso: http://192.168.1.100:61208

### Portainer
- Imagen: `${PORTAINER_IMAGE}` (define un tag o digest en `.env`)
- Puerto: 9000
- Acceso: http://192.168.1.100:9000

## Despliegue actual observado

- Compose runtime: `/srv/docker/dashboard/stack/compose.yaml`
- Config de Homepage: `/srv/docker/dashboard/stack/config/`
- Servicio systemd: `dashboard-stack.service`
- Compose legacy adicional detectado: `/srv/docker/dashboard/docker-compose.yml`

## Comandos útiles

Ver contenedores si el daemon está levantado:
```bash
docker ps
```

Ver logs:
```bash
docker logs homepage
docker logs glances
```

Reiniciar stack desplegado:
```bash
sudo systemctl restart dashboard-stack.service
```
