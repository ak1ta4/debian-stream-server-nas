# Sesión 20 Feb 2026 - Reconfiguración de Red y Tailscale

## 📋 Resumen
Sesión completa de reconfiguración tras problemas de red causados por Docker. Se eliminó el doble NAT, se configuró Tailscale con conexión directa, se limpiaron y renombraron los discos NAS, y se optimizó Samba para compatibilidad con iOS.

---

## 🔴 Problema Inicial: Docker Causando Loop de Red

### Síntoma
Al intentar configurar OpenVPN en el TP-Link, **el servidor tumbaba completamente el internet** de toda la casa cuando estaba conectado a la red.

### Diagnóstico
```bash
ip addr show
# Servidor tenía IP: 192.168.1.40
# Pero bridges de Docker creaban conflicto:
#   - br-ac0fb87f69c4: 172.24.0.1/16
#   - br-095822f1416e: 172.20.0.1/16
#   - docker0: 172.17.0.1/16
#   ... (múltiples bridges)
```

**Root cause:** Combinación de:
1. Doble NAT (TP-Link en modo router + Router ISP)
2. Múltiples bridges de Docker
3. Configuración de OpenVPN sin preparación

### Solución Inmediata
```bash
# Detener Docker completamente
sudo systemctl stop docker.socket
sudo systemctl stop docker
sudo systemctl disable docker

# Internet volvió a funcionar
```

---

## 🌐 Eliminación de Doble NAT

### Problema
**Doble NAT detectado:**
```bash
traceroute -n 8.8.8.8
1  192.168.0.1   # TP-Link (primera capa NAT)
2  192.168.1.1   # Router ISP (segunda capa NAT)
3  192.168.144.1 # Red ISP
```

### Solución: TP-Link como Access Point

**Configuración en TP-Link:**
1. Acceso: http://192.168.0.1
2. **Avanzado** → **Sistema** → **Modo de Operación**
3. Cambiar a: **Access Point**
4. Guardar y reiniciar

**Resultado:**
```bash
traceroute -n 8.8.8.8
1  192.168.1.1   # Router ISP (NAT único)
2  192.168.144.1 # Red ISP
```

✅ **Doble NAT eliminado**

---

## 🔄 Actualización de IPs

### Cambio de Subred

| Componente | IP Antigua | IP Nueva | Motivo |
|------------|-----------|----------|--------|
| Servidor | 192.168.0.10 | 192.168.1.40 | TP-Link ya no gestiona DHCP |
| Gateway | 192.168.0.1 (TP-Link) | 192.168.1.1 (Movistar) | TP-Link en modo AP |

### Servicios Actualizados

**Homepage Dashboard:**
```bash
nano /srv/docker/dashboard/stack/config/services.yaml
# Cambiar todas las IPs: 192.168.0.10 → 192.168.1.40
```

**Samba:**
- Automático (usa hostname/IP local)
- Reconexión manual en Windows necesaria

**Syncthing:**
```bash
nano ~/.local/state/syncthing/config.xml
# Actualizar rutas si necesario
```

---

## 🚀 Configuración de Tailscale

### Instalación
```bash
# Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Activar y compartir red local
sudo tailscale up --advertise-routes=192.168.1.0/24 --accept-routes
```

### Habilitar IP Forwarding
```bash
# Habilitar forwarding permanente
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf

# Aplicar
sudo sysctl -p
```

### Configuración UPnP en Router Movistar

**Router:** Askey RTF8115VW (Movistar)

1. Acceso: http://192.168.1.1
2. Usuario: `1234` / Contraseña: `1234`
3. **Configuración Avanzada** → **NAT** → **UPnP**
4. ✅ Habilitar UPnP
5. Guardar

### Aprobar Subnet Routes

1. https://login.tailscale.com/admin/machines
2. Buscar: **ak1t4-server**
3. **Edit route settings** → Aprobar `192.168.1.0/24`

### Verificación Conexión Directa
```bash
tailscale status
```

**Antes (con relay):**
```
100.126.34.53  iphone-15-pro  iOS  active; relay "mad", tx 573572 rx 125956
```

**Después (conexión directa):**
```
100.126.34.53  iphone-15-pro  iOS  active; direct 95.127.180.64:16177, tx 1571584 rx 293336
```

✅ **Conexión directa conseguida**

---

## 💾 Limpieza y Renombrado de Discos

### Problema
Nombres inconsistentes entre fstab, Samba, y Thunar:
- Disco 2TB: "Crucial-2TB" en algunos lugares, "/mnt/crucial-2tb" en otros
- Carpetas antiguas sobrando: `/mnt/seagate-4tb`, `/mnt/nas-main`, etc.

### Estructura Final

| Disco | Tamaño | Montaje | Etiqueta | Samba | Uso |
|-------|--------|---------|----------|-------|-----|
| Crucial X9 SSD | 2TB | `/mnt/nas-2tb` | NAS-2TB | `NAS-2TB` | Principal R/W |
| SSD | 220GB | `/mnt/nas-backup` | NAS-Backup | `NAS-Backup` | Backup R |
| SSD | 110GB | `/mnt/nas-snapshots` | NAS-Snapshots | `NAS-Snapshots` | Papelera R |

### Proceso de Limpieza
```bash
# 1. Detener servicios
systemctl --user stop syncthing
docker stop homepage portainer glances

# 2. Desmontar todo
sudo umount /mnt/nas-2tb
sudo umount /mnt/nas-backup
sudo umount /mnt/nas-snapshots

# 3. Cambiar etiquetas de filesystems
sudo e2label /dev/sdc2 "NAS-2TB"
sudo e2label /dev/sda1 "NAS-Backup"
sudo e2label /dev/sdb1 "NAS-Snapshots"

# 4. Actualizar fstab
sudo nano /etc/fstab
```

**fstab final:**
```
# Sistema
UUID=efe8a8c1-c4e9-4f66-a020-2ca61433625d  /               ext4  errors=remount-ro  0  1
UUID=AEF8-0792                             /boot/efi       vfat  umask=0077         0  1
UUID=1a547ccb-7084-470c-99fc-89cd4cd127c2  none            swap  sw                 0  0

# NAS Disks
UUID=eea07232-534c-4298-9782-3e3f8add79db  /mnt/nas-backup     ext4  defaults,nofail  0  2
UUID=4dd22b53-2ca9-4990-b92d-223443f6b386  /mnt/nas-snapshots  ext4  defaults,nofail  0  2
UUID=0ba6bce3-d58a-49e0-95a7-9d31e6fc8b72  /mnt/nas-2tb        ext4  defaults,nofail  0  2
```
```bash
# 5. Montar todo
sudo systemctl daemon-reload
sudo mount -a

# 6. Limpiar carpetas antiguas
sudo rmdir /mnt/crucial-2tb
sudo rmdir /mnt/seagate-4tb
sudo rmdir /mnt/nas-main
sudo rmdir /mnt/nas-storage

# 7. Limpiar contenido de discos (BORRA TODO)
sudo rm -rf /mnt/nas-backup/*
sudo rm -rf /mnt/nas-snapshots/*

# 8. Restaurar permisos
sudo chown -R ak1t4:ak1t4 /mnt/nas-2tb
sudo chown -R ak1t4:ak1t4 /mnt/nas-backup
sudo chown -R ak1t4:ak1t4 /mnt/nas-snapshots
```

---

## 🔧 Actualización de Samba

### Configuración Final

**/etc/samba/smb.conf:**
```ini
[global]
   # Optimizaciones de velocidad
   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288
   read raw = yes
   write raw = yes
   max xmit = 131072
   min receivefile size = 16384
   use sendfile = yes
   aio read size = 16384
   aio write size = 16384
   
   # Protocolo SMB3
   server min protocol = SMB2
   server max protocol = SMB3
   
   # Caché y rendimiento
   strict locking = no
   kernel oplocks = no

[NAS-2TB]
   comment = Almacenamiento Principal 2TB
   path = /mnt/nas-2tb
   browseable = yes
   read only = no
   writable = yes
   valid users = ak1t4
   create mask = 0664
   directory mask = 0775
   force user = ak1t4
   force group = ak1t4
   # Compatibilidad iOS
   vfs objects = fruit streams_xattr
   fruit:metadata = stream
   fruit:model = MacSamba
   fruit:posix_rename = yes
   fruit:veto_appledouble = no
   fruit:wipe_intentionally_left_blank_rfork = yes
   fruit:delete_empty_adfiles = yes

[NAS-Backup]
   comment = Backup Critico 220GB
   path = /mnt/nas-backup
   browseable = yes
   read only = yes
   valid users = ak1t4

[NAS-Snapshots]
   comment = Papelera y Snapshots 110GB
   path = /mnt/nas-snapshots
   browseable = yes
   read only = yes
   valid users = ak1t4
```
```bash
# Aplicar cambios
testparm
sudo systemctl restart smbd
```

---

## 🔄 Configuración de Syncthing

### Reset Completo
```bash
# Detener Syncthing
systemctl --user stop syncthing

# Limpiar configuración anterior
rm -rf ~/.local/state/syncthing

# Crear estructura de carpetas
mkdir -p /mnt/nas-2tb/Clases
mkdir -p /mnt/nas-2tb/Documentos
mkdir -p /mnt/nas-2tb/Imagenes
mkdir -p /mnt/nas-2tb/Videos

# Reiniciar
systemctl --user start syncthing
```

### Configuración

1. **Servidor:** http://192.168.1.40:8384
2. **Conectar dispositivos:**
   - Obtener Device ID del servidor
   - Añadir en PC Windows
3. **Añadir carpetas:**
   - Tipo: Send & Receive (bidireccional)
   - Carpetas: Clases, Documentos, Imagenes, Videos

---

## 🔧 Optimizaciones de Red

### Aumentar Buffers de Red
```bash
# Optimizar buffers TCP
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 67108864'
sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 67108864'

# Hacer permanente
echo "net.core.rmem_max=134217728" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max=134217728" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_rmem=4096 87380 67108864" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_wmem=4096 65536 67108864" | sudo tee -a /etc/sysctl.conf
```

---

## ✅ Estado Final del Sistema

### Red
- ✅ Sin doble NAT
- ✅ IP estática vía DHCP: 192.168.1.40
- ✅ UPnP habilitado en router ISP
- ✅ Tailscale con conexión directa (sin relay)

### Almacenamiento
- ✅ 3 discos limpios y correctamente nombrados
- ✅ Montaje automático vía fstab
- ✅ Permisos correctos (ak1t4:ak1t4)

### Servicios
- ✅ Docker funcionando sin causar loops
- ✅ Samba optimizado con compatibilidad iOS
- ✅ Syncthing sincronizando bidireccionalalmente
- ✅ Homepage, Portainer, Glances operativos

### Acceso Remoto
- ✅ Tailscale con conexión directa desde iPhone
- ✅ Acceso a red local 192.168.1.x desde cualquier lugar
- ✅ Samba funcional desde iPhone (app Archivos)

---

## 📊 Rendimiento

### Tailscale
- **Modo:** Direct (peer-to-peer)
- **Velocidad:** ~95-98% de WireGuard nativo
- **Latencia:** <5ms (red local virtual)

### Samba
- **Protocolo:** SMB3
- **Optimizaciones:** Buffers grandes, sendfile, aio
- **Dispositivos:** Windows 11, iPhone (iOS Files app)

---

## 🔍 Lecciones Aprendidas

### ❌ No Hacer
1. **No configurar VPN en router sin preparación** - Puede causar loops de red
2. **No usar doble NAT** - Complica conexiones directas y P2P
3. **No mezclar gestión de red automática y manual** - Elegir una estrategia

### ✅ Mejores Prácticas
1. **TP-Link como Access Point** - Simplifica la red, un solo NAT
2. **Tailscale > VPN router** - Más fácil, sin tocar router, funciona perfectamente
3. **Nombres consistentes** - Mismo nombre en fstab, Samba, y etiquetas
4. **Documentar cambios** - Fundamental cuando las cosas se complican

---

## 📝 Comandos Útiles Post-Configuración

### Verificar Estado
```bash
# Red
ip route show
tailscale status

# Discos
df -h | grep nas
sudo blkid | grep LABEL

# Servicios
docker ps
systemctl --user status syncthing
sudo systemctl status smbd
```

### Troubleshooting
```bash
# Si Tailscale pierde conexión directa
sudo tailscale down
sudo tailscale up --advertise-routes=192.168.1.0/24 --accept-routes

# Si Samba no responde
sudo systemctl restart smbd nmbd

# Si Syncthing falla
journalctl --user -u syncthing -f
```

---

**Duración de la sesión:** ~4 horas  
**Fecha:** 20 de Febrero de 2026  
**Estado final:** ✅ Todo funcionando correctamente
