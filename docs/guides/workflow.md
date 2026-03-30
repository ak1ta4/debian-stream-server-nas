# 🔄 Workflow de Mantenimiento

Guía para mantener el repositorio actualizado con los cambios del servidor.

## 📝 Cuando hagas cambios en el servidor

### 1. Realizar los cambios
Haz los cambios que necesites en tu servidor (instalar paquetes, modificar configs, añadir containers, etc.)

### 2. Actualizar configuraciones
```bash
cd ~/debian-stream-server-nas
./scripts/backup/update-configs.sh
```

Este script automáticamente copia:
- Configuraciones públicas de Sunshine
- Estado de contenedores Docker
- Inventario de systemd
- Autostart de XFCE

Los archivos sensibles como `sunshine_state.json`, `sshd_config` y snapshots de red deben mantenerse fuera del repo público.

### 3. Verificar cambios
```bash
git status
git diff
```

Revisa qué archivos han cambiado para asegurarte de que todo está correcto.

### 4. Añadir cambios
```bash
git add .
```

O añade archivos específicos:
```bash
git add configs/sunshine/
git add docs/setup/nueva-guia.md
```

### 5. Commit
```bash
git commit -m "Descripción clara del cambio"
```

Ejemplos de buenos mensajes:
- `git commit -m "Add Nextcloud container configuration"`
- `git commit -m "Update Sunshine to version 2026.xxx"`
- `git commit -m "Configure NAS on sda1 disk"`

### 6. Push a GitHub
```bash
git push
```

---

## 📸 Snapshots mensuales

Genera un snapshot completo del sistema cada mes:
```bash
cd ~/debian-stream-server-nas
./scripts/monitoring/system-inventory.sh
git add hardware/snapshots/
git commit -m "Monthly snapshot $(date +%Y-%m)"
git push
```

---

## 📋 Ejemplos de workflows completos

### Ejemplo 1: Añadir nuevo contenedor Docker
```bash
# 1. Crear y ejecutar el contenedor
docker run -d --name nuevo-servicio ...

# 2. Actualizar configs
cd ~/debian-stream-server-nas
./scripts/backup/update-configs.sh

# 3. Crear documentación
nano docs/setup/nuevo-servicio.md

# 4. Commit
git add .
git commit -m "Add nuevo-servicio Docker container"
git push
```

### Ejemplo 2: Actualizar Sunshine
```bash
# 1. Actualizar Sunshine en el servidor
sudo apt update && sudo apt upgrade sunshine

# 2. Reiniciar Sunshine
pkill sunshine

# 3. Actualizar configs y docs
cd ~/debian-stream-server-nas
./scripts/backup/update-configs.sh
nano docs/setup/sunshine-setup.md  # Actualizar versión

# 4. Commit
git add .
git commit -m "Update Sunshine to version X.X.X"
git push
```

### Ejemplo 3: Modificar configuración SSH
```bash
# 1. Editar config
sudo nano /etc/ssh/sshd_config

# 2. Reiniciar SSH
sudo systemctl restart ssh

# 3. Actualizar repo
cd ~/debian-stream-server-nas
./scripts/backup/update-configs.sh

# 4. Documentar cambio
echo "## Cambio en SSH config - $(date)" >> docs/operations/changelog.md
echo "- Descripción del cambio" >> docs/operations/changelog.md

# 5. Commit
git add .
git commit -m "Update SSH config: descripción"
git push
```

---

## 🔧 Comandos útiles

### Ver historial de cambios
```bash
git log --oneline -n 10
```

### Ver diferencias antes de commit
```bash
git diff
```

### Deshacer cambios no commiteados
```bash
git checkout -- archivo.txt
```

### Ver estado del repositorio
```bash
git status
```

---

## 📅 Rutina recomendada

### Diaria
- Revisar logs de servicios críticos
- Verificar que todos los contenedores están up

### Semanal
- Ejecutar `update-configs.sh` si hubo cambios
- Commit y push de cambios menores

### Mensual
- Generar snapshot con `system-inventory.sh`
- Revisar y actualizar documentación
- Actualizar paquetes del sistema
- Commit snapshot mensual

---

## ⚠️ Buenas prácticas

### DO ✅
- Hacer commits frecuentes con mensajes descriptivos
- Actualizar documentación junto con cambios de config
- Generar snapshots antes de cambios grandes
- Revisar `git status` antes de cada commit

### DON'T ❌
- Commitear credenciales o contraseñas
- Hacer commits gigantes con muchos cambios sin relación
- Olvidar actualizar la documentación
- Pushear sin revisar los cambios

---

## 🆘 Troubleshooting

### No puedo hacer push
```bash
git pull --rebase origin main
git push
```

### Me equivoqué en el último commit
```bash
# Cambiar mensaje
git commit --amend -m "Nuevo mensaje"

# Añadir archivos olvidados
git add archivo-olvidado.txt
git commit --amend --no-edit
```

### Conflictos al hacer pull
```bash
# Ver archivos en conflicto
git status

# Aceptar tu versión
git checkout --ours archivo.txt

# Aceptar versión remota
git checkout --theirs archivo.txt

# Después de resolver
git add .
git commit -m "Resolve merge conflict"
```

---

## 🐳 Gestión con Docker Compose

### Usar docker compose en lugar de comandos docker

Si migraste a `docker compose`, usa estos comandos:
```bash
cd ~/debian-stream-server-nas

# Iniciar todos los servicios
docker compose up -d

# Ver logs
docker compose logs -f

# Reiniciar un servicio
docker compose restart homepage

# Parar todo
docker compose down

# Actualizar imágenes
docker compose pull
docker compose up -d
```

### Añadir nuevo servicio al compose

1. Editar docker-compose.yml:
```bash
nano docker-compose.yml
```

2. Añadir el servicio (ejemplo):
```yaml
  nuevo-servicio:
    image: imagen:latest
    container_name: nuevo-servicio
    ports:
      - "8080:8080"
    restart: unless-stopped
    networks:
      - dashboard
```

3. Aplicar cambios:
```bash
docker compose up -d
```

4. Actualizar repo:
```bash
./scripts/backup/update-configs.sh
git add docker-compose.yml
git commit -m "Add nuevo-servicio to docker compose"
git push
```
