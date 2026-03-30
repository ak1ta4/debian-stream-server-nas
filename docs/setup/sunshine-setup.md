# Sunshine Streaming

## Informacion
- Version: 2025.924.154138
- Publisher: LizardByte
- Binario: /usr/bin/sunshine

## Configuracion
Archivos en: `~/.config/sunshine/`
- `apps.json`
- `sunshine.conf`
- `sunshine_state.json`

## Autostart
Sunshine arranca con `systemd --user`.

- Archivo versionado: `configs/systemd-user/sunshine.service`
- Archivo real del usuario: `~/.config/systemd/user/sunshine.service`

## DPMS Deshabilitado
Para evitar que se apague la pantalla:

- Archivo: `~/.config/autostart/disable-dpms.desktop`

## Acceso
- WebUI: `https://localhost:47990`
- Puerto streaming: `47989`

## Pairing
1. Abrir Moonlight
2. Anadir PC: `192.168.1.100`
3. Introducir PIN
4. Seleccionar Desktop

## Apps configuradas actualmente
- Desktop
- Low Res Desktop
- Steam Big Picture

## GPU
- NVIDIA RTX 3050 Mobile (encoding)
- AMD Radeon Vega (integrada)
