# Docker Setup

## Contenedores Activos

### Homepage
- Imagen: ghcr.io/gethomepage/homepage:latest
- Puerto: 3000
- Acceso: http://192.168.1.55:3000

### Glances
- Imagen: nicolargo/glances:latest
- Puerto: 61208
- Acceso: http://192.168.1.55:61208

### Portainer
- Imagen: portainer/portainer-ce:latest
- Puerto: 9000
- Acceso: http://192.168.1.55:9000

## Comandos Utiles

Ver contenedores:
```
docker ps
```

Ver logs:
```
docker logs homepage
docker logs glances
```

Reiniciar:
```
docker restart homepage
```
