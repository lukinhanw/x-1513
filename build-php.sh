#!/bin/bash
set -e

echo -e "\n=== Compilando PHP 7.4.33 para XUI.one ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH=$(uname -m)

# Identificar SO
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

echo "SO Detectado: $OS $VER ($ARCH)"

# Garantir dependências de compilação
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null 2>&1 || true
apt-get install -y -qq build-essential libxml2-dev libssl-dev libcurl4-openssl-dev \
    libjpeg-dev libpng-dev libfreetype6-dev libxslt1-dev libonig-dev pkg-config \
    bison re2c patch wget curl tar gzip >/dev/null 2>&1 || true

BUILD_DIR="/root/phpbuild"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Baixar PHP 7.4.33 de fontes redundantes
PHP_TAR="$BUILD_DIR/php-7.4.33.tar.gz"
if [ ! -f "$PHP_TAR" ]; then
    if [ -f "$SCRIPT_DIR/php-7.4.33.tar.gz" ]; then
        cp "$SCRIPT_DIR/php-7.4.33.tar.gz" "$PHP_TAR"
    elif [ -f "/home/xui/www/downloads/php-7.4.33.tar.gz" ]; then
        cp "/home/xui/www/downloads/php-7.4.33.tar.gz" "$PHP_TAR"
    else
        echo "Baixando código-fonte do PHP 7.4.33..."
        wget --no-check-certificate -q "http://208.87.243.165/downloads/php-7.4.33.tar.gz" -O "$PHP_TAR" || \
        wget --no-check-certificate -q "https://www.php.net/distributions/php-7.4.33.tar.gz" -O "$PHP_TAR" || \
        wget --no-check-certificate -q "https://museum.php.net/php7/php-7.4.33.tar.gz" -O "$PHP_TAR"
    fi
fi

if [ ! -f "$PHP_TAR" ]; then
    echo "Erro: Não foi possível obter o código-fonte do php-7.4.33.tar.gz!"
    exit 1
fi

rm -rf "$BUILD_DIR/php-7.4.33"
tar -xzf "$PHP_TAR"
cd "$BUILD_DIR/php-7.4.33"

# Aplicar patch OpenSSL 3.0 para Ubuntu 22.04 / 24.04 / Debian 11+
PATCH_FILE="$SCRIPT_DIR/patches/0060-Add-minimal-OpenSSL-3.0-patch.patch"
if [ -f "$PATCH_FILE" ]; then
    echo "Aplicando patch OpenSSL 3.0..."
    patch -p1 < "$PATCH_FILE" || true
fi

echo "Configurando compilação do PHP..."
./configure \
    --prefix=/home/xui/bin/php \
    --with-fpm-user=xui \
    --with-fpm-group=xui \
    --enable-gd \
    --with-jpeg \
    --with-freetype \
    --enable-static \
    --disable-shared \
    --enable-opcache \
    --enable-fpm \
    --without-sqlite3 \
    --without-pdo-sqlite \
    --enable-mysqlnd \
    --with-mysqli \
    --with-curl \
    --disable-cgi \
    --with-zlib \
    --enable-sockets \
    --with-openssl \
    --enable-shmop \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-calendar \
    --disable-rpath \
    --enable-inline-optimization \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --with-mhash \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl \
    --with-libxml \
    --with-pdo-mysql \
    --disable-mbregex

echo "Compilando PHP (pode levar alguns minutos)..."
CORES=$(nproc 2>/dev/null || echo 2)
make -j"$CORES"

echo "Instalando PHP em /home/xui/bin/php..."
killall -9 php php-fpm 2>/dev/null || true
chattr -i /home/xui/bin/php/sbin/php-fpm 2>/dev/null || true
chattr -i /home/xui/bin/php/bin/php 2>/dev/null || true

make install

cd /root
rm -rf "$BUILD_DIR"

chattr +i /home/xui/bin/php/sbin/php-fpm 2>/dev/null || true
chattr +i /home/xui/bin/php/bin/php 2>/dev/null || true

echo "PHP 7.4.33 compilado e instalado com sucesso!"

