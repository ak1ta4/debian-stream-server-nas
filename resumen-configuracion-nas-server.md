# Configuración del Servidor NAS - ak1t4-server

> **Nota de Seguridad:** Este documento utiliza IPs de ejemplo (192.168.1.100). Para las IPs reales de tu red, consulta el submodule privado `config-privado/` (repositorio privado en GitHub).
> **Actualizado:** 30 de marzo de 2026. Los datos de hardware y servicios se han alineado con el inventario actual del sistema; las secciones de NAS/discos externos mantienen contexto histórico y deben revalidarse si el almacenamiento externo vuelve a conectarse.

## 📋 Índice
1. [Arquitectura del Sistema](#arquitectura-del-sistema)
2. [Configuración de Discos y NAS](#configuración-de-discos-y-nas)
3. [Configuración de Samba](#configuración-de-samba)
4. [Actualización de Red](#actualización-de-red)
5. [Configuración de Homepage Dashboard](#configuración-de-homepage-dashboard)
6. [Instalación de Syncthing](#instalación-de-syncthing)
7. [Estado Actual del Sistema](#estado-actual-del-sistema)
8. [Pendientes](#pendientes)
9. [Comandos Útiles](#comandos-útiles)

---

## 🏗️ Arquitectura del Sistema
```
┌─────────────────────────────────────────────────────────────┐
│                SERVIDOR NAS (192.168.1.100)                 │
├─────────────────────────────────────────────────────────────┤
│  Inventario detectado en esta actualización:                │
│  ┌──────────────┐                                           │
│  │ NVMe 476.9GB │                                           │
│  │ Sistema OS   │                                           │
│  │      /       │                                           │
│  └──────────────┘                                           │
│  Discos NAS externos: no detectados en este inventario      │
│                                                             │
│  Servicios:                                                 │
│  • Sunshine ─── systemd --user                             │
│  • Samba ────── Puerto 445                                 │
│  • SSH ──────── Puerto 22                                  │
│  • Tailscale ── tailscaled.service                         │
│  • Apache2 ───── Puerto 80/443                             │
│  • Dashboard ─── Homepage + Glances                        │
└─────────────────────────────────────────────────────────────┘
                            │
                    Red Local (192.168.1.x)
                            │
┌─────────────────────────────────────────────────────────────┐
│                    PC WINDOWS 11                            │
├─────────────────────────────────────────────────────────────┤
│  Discos Mapeados (Samba):                                   │
│  • Z:\ → \\192.168.1.100\Crucial-2TB  (R/W)               │
│  • Y:\ → \\192.168.1.100\NAS-Main     (Solo lectura)      │
│  • X:\ → \\192.168.1.100\Snapshots    (Solo lectura)      │
│                                                             │
│  Syncthing: (pendiente configuración completa)              │
│  • Sincronización bidireccional de carpetas importantes     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Configuración de Discos y NAS

> **Nota:** las subsecciones siguientes documentan la configuración NAS histórica del servidor. En el inventario del `2026-03-30` solo se detectó el NVMe del sistema; no se detectaron discos externos montados.

### Distribución Final de Discos

| Disco | Tamaño | Punto de Montaje | Propósito |
|-------|--------|-----------------|-----------|
| NVMe | 450GB | `/` | Sistema operativo |
| SSD | 220GB | `/mnt/nas-main` | Backup crítico |
| SSD | 110GB | `/mnt/nas-backup` | Papelera/Snapshots |
| Crucial X9 | 2TB | `/mnt/crucial-2tb` | Almacenamiento principal |

### Preparación del Crucial X9 2TB
```bash
# 1. Desmontar (estaba en exFAT por defecto)
sudo umount "/media/ak1t4/Crucial X9"

# 2. Formatear a ext4
sudo mkfs.ext4 -L "Crucial-2TB" /dev/sdc2

# 3. Crear punto de montaje
sudo mkdir -p /mnt/crucial-2tb

# 4. Obtener UUID
sudo blkid /dev/sdc2

# 5. Montar el disco
sudo mount /dev/sdc2 /mnt/crucial-2tb

# 6. Asignar permisos
sudo chown -R ak1t4:ak1t4 /mnt/crucial-2tb

# 7. Verificar
df -h | grep crucial
```

### Configuración del fstab

**Archivo:** `/etc/fstab`
```
# Sistema
UUID=efe8a8c1-c4e9-4f66-a020-2ca61433625d  /                ext4    errors=remount-ro  0  1
UUID=AEF8-0792                             /boot/efi        vfat    umask=0077         0  1
UUID=1a547ccb-7084-470c-99fc-89cd4cd127c2  none             swap    sw                 0  0

# NAS Disks
UUID=eea07232-534c-4298-9782-3e3f8add79db  /mnt/nas-main    ext4    defaults,nofail    0  2
UUID=4dd22b53-2ca9-4990-b92d-223443f6b386  /mnt/nas-backup  ext4    defaults,nofail    0  2
UUID=0ba6bce3-d58a-49e0-95a7-9d31e6fc8b72  /mnt/crucial-2tb ext4    defaults,nofail    0  2
```
```bash
# Recargar systemd y montar
sudo systemctl daemon-reload
sudo mount -a
```

---

## 🌐 Configuración de Samba

### Instalación
```bash
sudo apt update
sudo apt install samba -y
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
```

### Recursos Compartidos

**Archivo:** `/etc/samba/smb.conf` (añadir al final)
```ini
[Crucial-2TB]
   comment = Almacenamiento Principal 2TB
   path = /mnt/crucial-2tb
   browseable = yes
   read only = no
   writable = yes
   valid users = ak1t4
   create mask = 0775
   directory mask = 0775

[NAS-Main]
   comment = Backup Critico 220GB
   path = /mnt/nas-main
   browseable = yes
   read only = yes
   valid users = ak1t4

[Snapshots]
   comment = Papelera y Snapshots 110GB
   path = /mnt/nas-backup
   browseable = yes
   read only = yes
   valid users = ak1t4
```

### Usuario y Firewall
```bash
# Crear usuario Samba
sudo smbpasswd -a ak1t4

# Verificar configuración
testparm

# Reiniciar servicios
sudo systemctl restart smbd
sudo systemctl restart nmbd

# Abrir firewall
sudo ufw allow Samba
```

### Mapeo en Windows 11

| Letra | Ruta | Permisos | Propósito |
|-------|------|----------|-----------|
| Z: | `\\192.168.1.100\Crucial-2TB` | R/W | Almacenamiento principal |
| Y: | `\\192.168.1.100\NAS-Main` | Solo lectura | Ver backups |
| X: | `\\192.168.1.100\Snapshots` | Solo lectura | Recuperar archivos |

---

## 🔄 Actualización de Red

### Cambio de Subred

| | Antes | Después |
|--|-------|---------|
| IP del servidor | `192.168.0.100` | `192.168.1.100` |
| Motivo | Cambio de router | — |

### Homepage - Solución de validación
```bash
# Downgrade a v0.8.8 (sin validación estricta)
docker rm -f homepage
docker run -d \
  --name homepage \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /srv/docker/dashboard/stack/config:/app/config \
  ghcr.io/gethomepage/homepage:v0.8.8
```

**Actualizar IPs en:** `/srv/docker/dashboard/stack/config/services.yaml`

---

## 📊 Configuración de Homepage Dashboard

### Archivos de Configuración

**`settings.yaml`**
```yaml
---
title: Server Dashboard
```

**`widgets.yaml`**
```yaml
- datetime:
    text_size: xl
    format:
      timeStyle: short
      dateStyle: long

- resources:
    cpu: true
    memory: true
    disk: /
```

**`services.yaml`**
```yaml
- Infra:
    - Homepage:
        href: http://192.168.1.100:3000
        description: Dashboard
        icon: homepage
    - Glances:
        href: http://192.168.1.100:61208
        description: Métricas
        icon: glances

- Streaming:
    - Sunshine:
        href: https://192.168.1.100:47990
        description: Sunshine UI
        icon: sunshine
```

---

## 🔄 Instalación de Syncthing

### Instalación
```bash
# Añadir repositorio oficial
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Instalar
sudo apt update
sudo apt install syncthing -y

# Habilitar para el usuario
systemctl --user enable syncthing.service
systemctl --user start syncthing.service
```

### Configurar Acceso Remoto

Editar: `~/.local/state/syncthing/config.xml`

Cambiar:
```xml
<address>127.0.0.1:8384</address>
```

Por:
```xml
<address>0.0.0.0:8384</address>
```
```bash
systemctl --user restart syncthing
```

### Firewall
```bash
sudo ufw allow 22000/tcp comment 'Syncthing transfers'
sudo ufw allow 21027/udp comment 'Syncthing discovery'
sudo ufw allow 8384/tcp comment 'Syncthing Web UI'
```

### Acceso

- **Interfaz web:** http://192.168.1.100:8384

---

## ✅ Estado Actual del Sistema

### Servicios

| Servicio | URL | Estado |
|----------|-----|--------|
| Sunshine | https://192.168.1.100:47990 | ✅ proceso detectado |
| Samba | `\\192.168.1.100` | ✅ `smbd` y `nmbd` activos |
| SSH | `ssh ak1t4@192.168.1.100` | ✅ `ssh.service` activo |
| Tailscale | red privada | ✅ `tailscaled.service` activo |
| Apache2 | http://192.168.1.100 | ✅ `apache2.service` activo |
| Dashboard stack | `/srv/docker/dashboard/stack/compose.yaml` | configurado vía `dashboard-stack.service` |

---

## 📝 Pendientes

### 1. Completar Syncthing
- [ ] Conectar dispositivos servidor ↔ Windows
- [ ] Configurar carpetas con Send & Receive
- [ ] Verificar sincronización

### 2. Backups Automáticos
```bash
#!/bin/bash
# /home/ak1t4/scripts/backup-critical.sh
DATE=$(date +%Y-%m-%d)
echo "[$DATE] Iniciando backup..."
rsync -av --delete /mnt/crucial-2tb/syncthing/Documentos/ /mnt/nas-main/backup/documentos/
rsync -av --delete /mnt/crucial-2tb/syncthing/Fotos/ /mnt/nas-main/backup/fotos/
echo "[$DATE] Completado."
```
```bash
chmod +x /home/ak1t4/scripts/backup-critical.sh
crontab -e
# Añadir: 0 2 * * * /home/ak1t4/scripts/backup-critical.sh
```

### 3. Papelera Inteligente
- [ ] Sistema de retención 30-60 días en `/mnt/nas-backup`

---

## 📚 Comandos Útiles

### Discos
```bash
lsblk -f                          # Ver discos
df -h                             # Espacio disponible
sudo blkid                        # UUIDs
sudo mount -a                     # Montar todo
sudo systemctl daemon-reload      # Recargar tras cambios
```

### Samba
```bash
sudo systemctl restart smbd       # Reiniciar
testparm                          # Verificar config
sudo smbpasswd ak1t4              # Cambiar contraseña
```

### Syncthing
```bash
systemctl --user status syncthing    # Estado
systemctl --user restart syncthing   # Reiniciar
journalctl --user -u syncthing -f    # Logs
```

### Docker
```bash
docker ps                            # Contenedores activos
docker logs <nombre> --tail 50       # Ver logs
docker restart <nombre>              # Reiniciar
```

---

**Última actualización:** 30 de Marzo de 2026
**Usuario:** ak1t4
**IP del Servidor:** 192.168.1.100 (ejemplo - ver config-privado/ para IPs reales)
**SO:** Debian GNU/Linux 13.3 (Trixie)
