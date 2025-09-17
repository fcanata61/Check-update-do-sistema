#!/bin/bash
PKG=$1
RECIPEDIR="/var/lib/meupkg/recipes/$PKG"
INSTALLED_DB="/var/lib/meupkg/installed.db"
PKGDIR="/tmp/$PKG-pkgdir"

if [ -z "$PKG" ]; then
    echo "Uso: meupkg upgrade <pacote>"
    exit 1
fi

# Pegar a versão mais nova do check-updates
LATEST_JSON=$(./check-updates.sh)
NEW_VERSION=$(echo "$LATEST_JSON" | jq -r --arg p "$PKG" '.[$p]')

if [ "$NEW_VERSION" == "null" ]; then
    echo "Não foi possível encontrar versão upstream para $PKG"
    exit 1
fi

# Atualiza a versão na receita
RECIPE_FILE="$RECIPEDIR/build.sh"
sed -i "s/^version=.*/version=\"$NEW_VERSION\"/" "$RECIPE_FILE"
sed -i "s|^url=.*|url=\"https://github.com/$PKG/$PKG/archive/refs/tags/v\${version}.tar.gz\"|" "$RECIPE_FILE"

# Carregar a receita atualizada
source "$RECIPE_FILE"

echo "==> Atualizando $name para versão $version"

# Baixar fonte
curl -L -o ${name}-${version}.tar.gz "$url"

# Criar diretório temporário
rm -rf "$PKGDIR"
mkdir -p "$PKGDIR"

# Compilar
build

# Instalar
install_pkg

# Copiar para o sistema
cp -r "$PKGDIR"/* /

# Atualizar banco de pacotes
sed -i "/^$name=/d" "$INSTALLED_DB"
echo "$name=$version" >> "$INSTALLED_DB"

echo "==> $name atualizado para versão $version ✅"
