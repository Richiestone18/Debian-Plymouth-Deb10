# Debian-Plymouth-Deb10

Tema de **Plymouth** (bootscreen) estilo Windows 10 para **Debian 13 (Trixie)** y otras versiones de Debian.

Incluye el script de instalación remota que se puede usar con `wget` y `chmod`, y que descarga automáticamente todos los archivos necesarios desde GitHub.

## Archivos del tema

- `deb10.plymouth` — definición del tema
- `deb10.script` — script de animación de Plymouth
- `box.png`, `bullet.png`, `dot.png`, `entry.png`, `lock.png`, `logo.png`, `progress_bar.png`, `progress_box.png` — recursos gráficos

## Uso (instalación remota)

Descarga e instala en tres comandos:

```bash
wget https://raw.githubusercontent.com/Richiestone18/Debian-Plymouth-Deb10/main/install-deb10-plymouth.sh
chmod +x install-deb10-plymouth.sh
sudo bash install-deb10-plymouth.sh
sudo reboot
```

## ¿Qué hace el script?

1. Descarga todos los archivos del tema desde este repositorio (`.plymouth`, `.script`, `.png`).
2. Instala `plymouth`, `plymouth-themes` y `make` si faltan.
3. Copia el tema a `/usr/share/plymouth/themes/deb10/`.
4. Establece `deb10` como tema por defecto con `plymouth-set-default-theme -R deb10`.
5. Agrega `quiet splash` a `GRUB_CMDLINE_LINUX_DEFAULT` en `/etc/default/grub` (hace respaldo previo).
6. Ejecuta `update-grub`.

## Requisitos

- Debian con Plymouth
- `wget` o `curl`
- Ejecutar como root (`sudo`)
- Conexión a internet (para descargar desde GitHub)

## Créditos

Tema original "Deb10" de Mauro A. Meloni (maumeloni@gmail.com), basado en "Pure CSS Windows10 Loader" de Fernando de Almeida Faria.
