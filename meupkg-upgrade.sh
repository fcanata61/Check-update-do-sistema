#!/bin/bash
# meupkg upgrade <pacote>

PKG=$1
RECIPEDIR="/var/lib/meupkg/recipes/$PKG"
INSTALLED_DB="/var/lib/meupkg/installed.db"
PKGDIR="/tmp/$PKG-pkgdir"

if [ -z "$PKG" ]; then
    echo "Uso: meupkg upgrade <pacote>"
    exit 1
fi

if [ ! -d "$RECIPEDIR" ]; then
    echo "Erro: receita para '$PKG' não encontrada em $RECIPEDIR"
    exit 1
fi

# Carregar a receita
source "$RECIPEDIR/build.sh"

echo "==> Atualizando $name para versão $version"

# Baixar fonte
echo "==> Baixando $url"
curl -L -o ${name}-${version}.tar.* "$url"

# Criar diretório temporário de instalação
rm -rf "$PKGDIR"
mkdir -p "$PKGDIR"

# Compilar
echo "==> Compilando..."
build

# Instalar
echo "==> Instalando em $PKGDIR"
install_pkg

# Copiar para o sistema
echo "==> Copiando para /"
cp -r "$PKGDIR"/* /

# Atualizar banco de pacotes
sed -i "/^$name=/d" "$INSTALLED_DB"
echo "$name=$version" >> "$INSTALLED_DB"

echo "==> $name atualizado para versão $version ✅"
