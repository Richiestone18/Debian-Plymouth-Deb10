#!/bin/bash
###############################################################################
# Instalador remoto del tema Plymouth "deb10" (bootscreen estilo Windows 10)
# Para Debian 13 (Trixie) y otras versiones de Debian con Plymouth.
#
# Uso:
#   wget https://raw.githubusercontent.com/Richiestone18/Debian-Plymouth-Deb10/main/install-deb10-plymouth.sh
#   chmod +x install-deb10-plymouth.sh
#   sudo bash install-deb10-plymouth.sh
#
# Este script descarga automáticamente los archivos del tema desde GitHub
# (deb10.plymouth, deb10.script y los .png) y los instala.
#
# Requisitos: ejecutar como root (sudo).
###############################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*"; }
header() { echo -e "\n${CYAN}========================================${NC}"; echo -e "${CYAN}  $*${NC}"; echo -e "${CYAN}========================================${NC}\n"; }

# Configuración del repositorio remoto
REPO_USER="Richiestone18"
REPO_NAME="Debian-Plymouth-Deb10"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}"

# Archivos necesarios del tema (todos deben estar en el repo)
FILES_NEEDED=(
    "deb10.plymouth"
    "deb10.script"
    "box.png"
    "bullet.png"
    "dot.png"
    "entry.png"
    "lock.png"
    "logo.png"
    "progress_bar.png"
    "progress_box.png"
)

###############################################################################
# 0. VERIFICACIONES PREVIAS
###############################################################################
header "Verificando requisitos previos"

if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root (sudo)."
    exit 1
fi

if ! command -v wget &>/dev/null && ! command -v curl &>/dev/null; then
    error "Se necesita wget o curl para descargar los archivos desde GitHub."
    exit 1
fi

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    log "Sistema detectado: $PRETTY_NAME"
fi

###############################################################################
# 1. DESCARGAR ARCHIVOS DESDE GITHUB
###############################################################################
header "Descargando archivos del tema desde GitHub"

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

download_file() {
    local file="$1"
    local url="${RAW_BASE}/${file}"
    local out="${TMP_DIR}/${file}"
    if command -v wget &>/dev/null; then
        wget -q "$url" -O "$out"
    else
        curl -fsSL "$url" -o "$out"
    fi
    if [[ ! -s "$out" ]]; then
        error "No se pudo descargar: $file"
        exit 1
    fi
    log "Descargado: $file"
}

for f in "${FILES_NEEDED[@]}"; do
    download_file "$f"
done

THEME_DIR="$TMP_DIR"
log "Todos los archivos descargados en $THEME_DIR"

###############################################################################
# 2. INSTALAR DEPENDENCIAS
###############################################################################
header "Instalando dependencias (plymouth, plymouth-themes, make)"

if ! dpkg -s plymouth &>/dev/null || ! dpkg -s plymouth-themes &>/dev/null || ! dpkg -s make &>/dev/null; then
    apt update
    apt install -y plymouth plymouth-themes make
    log "Dependencias instaladas"
else
    log "Dependencias ya instaladas"
fi

###############################################################################
# 3. COPIAR TEMA A /usr/share/plymouth/themes/deb10/
###############################################################################
header "Instalando tema Plymouth deb10"

THEME_TARGET="/usr/share/plymouth/themes/deb10"

if [[ -d "$THEME_TARGET" ]]; then
    rm -rv "$THEME_TARGET"
fi

mkdir -p "$THEME_TARGET"
cp -v "$THEME_DIR"/*.script "$THEME_DIR"/*.plymouth "$THEME_DIR"/*.png "$THEME_TARGET/"

log "Tema copiado en $THEME_TARGET"

###############################################################################
# 4. ESTABLECER COMO TEMA POR DEFECTO
###############################################################################
header "Estableciendo deb10 como tema por defecto"

plymouth-set-default-theme -R deb10
log "Tema deb10 establecido como predeterminado"

###############################################################################
# 5. CONFIGURAR GRUB (quiet splash)
###############################################################################
header "Configurando GRUB para mostrar el bootscreen"

GRUB_FILE="/etc/default/grub"

if [[ ! -f "$GRUB_FILE" ]]; then
    error "No se encontró $GRUB_FILE"
    exit 1
fi

if [[ ! -f "${GRUB_FILE}.bak-deb10plymouth" ]]; then
    cp "$GRUB_FILE" "${GRUB_FILE}.bak-deb10plymouth"
    log "Respaldo de grub guardado en ${GRUB_FILE}.bak-deb10plymouth"
fi

if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"; then
    sed -i 's/quiet//g; s/splash//g' "$GRUB_FILE"
    sed -i 's/  */ /g' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 quiet splash"/' "$GRUB_FILE"
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' >> "$GRUB_FILE"
fi

log "GRUB configurado con quiet splash"

###############################################################################
# 6. ACTUALIZAR GRUB
###############################################################################
header "Actualizando configuración de GRUB"

update-grub
log "GRUB actualizado"

###############################################################################
# FIN
###############################################################################
header "INSTALACIÓN COMPLETADA"

echo ""
log "El tema Plymouth 'deb10' está instalado y configurado."
echo ""
warn "IMPORTANTE: Debes reiniciar la computadora para ver el bootscreen al iniciar."
echo ""
echo "  sudo reboot"
echo ""
echo "Si quieres volver al tema anterior, restaura el respaldo de grub:"
echo "  sudo cp /etc/default/grub.bak-deb10plymouth /etc/default/grub"
echo "  sudo update-grub"
echo ""
