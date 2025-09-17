#!/bin/bash
INSTALLED_DB="/var/lib/meupkg/installed.db"
LATEST_JSON=$(./check-updates.sh)
PKGDIR="/tmp/meupkg-pkgdir"

echo "=== Pacotes com updates disponíveis ==="

# Loop por cada pacote instalado
while IFS='=' read -r pkg ver_inst; do
    ver_latest=$(echo "$LATEST_JSON" | jq -r --arg p "$pkg" '.[$p]')
    if [ "$ver_latest" != "null" ] && [ "$ver_latest" != "$ver_inst" ]; then
        echo "→ $pkg: $ver_inst → $ver_latest"
        read -p "Quer atualizar $pkg? [y/N]: " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "Atualizando $pkg..."
            RECIPEDIR="/var/lib/meupkg/recipes/$pkg"
            RECIPE_FILE="$RECIPEDIR/build.sh"

            # Atualiza versão na receita automaticamente
            sed -i "s/^version=.*/version=\"$ver_latest\"/" "$RECIPE_FILE"
            case "$pkg" in
                vim)
                    sed -i "s|^url=.*|url=\"https://github.com/vim/vim/archive/refs/tags/v\${version}.tar.gz\"|" "$RECIPE_FILE"
                    ;;
                xorg-server)
                    sed -i "s|^url=.*|url=\"https://www.x.org/releases/individual/xserver/$pkg-\${version}.tar.xz\"|" "$RECIPE_FILE"
                    ;;
                firefox)
                    sed -i "s|^url=.*|url=\"https://ftp.mozilla.org/pub/firefox/releases/\${version}/source/firefox-\${version}.source.tar.xz\"|" "$RECIPE_FILE"
                    ;;
                chromium)
                    sed -i "s|^url=.*|url=\"https://commondatastorage.googleapis.com/chromium-browser-official/chromium-\${version}.tar.xz\"|" "$RECIPE_FILE"
                    ;;
            esac

            # Carregar a receita
            source "$RECIPE_FILE"

            # Baixar fonte
            curl -L -o ${name}-${version}.tar.* "$url"

            # Preparar diretório temporário
            rm -rf "$PKGDIR"
            mkdir -p "$PKGDIR"

            # Compilar e instalar
            build
            install_pkg
            cp -r "$PKGDIR"/* /

            # Atualizar banco de pacotes
            sed -i "/^$name=/d" "$INSTALLED_DB"
            echo "$name=$version" >> "$INSTALLED_DB"

            echo "==> $name atualizado para versão $version ✅"
        else
            echo "Pulando $pkg..."
        fi
    fi
done < "$INSTALLED_DB"

echo "=== Atualizações concluídas ==="
