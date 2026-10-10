#!/bin/bash
set -e

echo -e "\n==============================================="
echo "   XUI.one 1.5.13 - Auto Installer Standalone  "
echo "==============================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Identificação do SO
if [ -f /etc/os-release ]; then
    OS="$(grep -w ID /etc/os-release | sed 's/^.*=//' | tr -d '"')"
    VER="$(grep -w VERSION_ID /etc/os-release | sed 's/^.*=//' | tr -d '"')"
elif [ -f /etc/lsb-release ]; then
    OS="$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')"
    VER="$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')"
else
    OS="$(uname -s)"
    VER="$(uname -r)"
fi
ARCH="$(uname -m)"

echo "Sistema Detectado: $OS $VER ($ARCH)"

if [[ "$ARCH" != "x86_64" ]]; then
    echo "Erro: Apenas arquitetura x86_64 é suportada pelo XUI.one!"
    exit 1
fi

if [[ "$OS" != "Ubuntu" && "$OS" != "ubuntu" && "$OS" != "debian" && "$OS" != "Debian" ]]; then
    echo "Aviso: Sistema operacional recomendado: Ubuntu 20.04 / 22.04 / 24.04."
fi

# Instalação de utilitários base
echo "Instalando pré-requisitos essenciais..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null 2>&1 || true
apt-get install -y -qq python3 python3-dev unzip wget curl git build-essential >/dev/null 2>&1 || true

ZIP_NAME="XUI_1.5.13.zip"
TARGET_DIR="/root"
cd "$TARGET_DIR"

# Verificar se o arquivo já existe localmente
if [ ! -f "$TARGET_DIR/$ZIP_NAME" ] && [ ! -f "$SCRIPT_DIR/$ZIP_NAME" ]; then
    PRIMARY_URL="${XUI_URL:-http://208.87.243.165/downloads/XUI_1.5.13.zip}"
    FALLBACK_URL="https://github.com/lukinhanw/x-1513/releases/download/v1.5.13/XUI_1.5.13.zip"

    echo "Baixando $ZIP_NAME..."
    if ! wget --no-check-certificate -q --show-progress "$PRIMARY_URL" -O "$TARGET_DIR/$ZIP_NAME"; then
        echo "Falha no link primário. Tentando mirror secundário..."
        wget --no-check-certificate -q --show-progress "$FALLBACK_URL" -O "$TARGET_DIR/$ZIP_NAME" || {
            echo "Erro: Falha ao baixar $ZIP_NAME! Verifique a conexão ou passe XUI_URL=http://... ./install.sh"
            exit 1
        }
    fi
elif [ -f "$SCRIPT_DIR/$ZIP_NAME" ] && [ ! -f "$TARGET_DIR/$ZIP_NAME" ]; then
    cp "$SCRIPT_DIR/$ZIP_NAME" "$TARGET_DIR/$ZIP_NAME"
fi

echo "Descompactando $ZIP_NAME..."
unzip -o "$TARGET_DIR/$ZIP_NAME" -d "$TARGET_DIR" >/dev/null 2>&1

# Executar instalador Python
chmod +x "$SCRIPT_DIR/install.python3"
chmod +x "$SCRIPT_DIR/build-php.sh"

echo "Iniciando instalação automatizada..."
python3 "$SCRIPT_DIR/install.python3"

