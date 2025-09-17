#!/bin/bash
# Gerenciador integrado: check-updates + upgrade interativo por grupo
INSTALLED_DB="/var/lib/meupkg/installed.db"
PKGDIR="/tmp/meupkg-pkgdir"
GROUP=$1

# Simulação de JSON de versões upstream (substitua por consultas reais)
LATEST_JSON='{
    "vim":"9.1.0790",
    "xorg-server":"21.1.13",
    "firefox":"132.0",
    "chromium":"130.0.6700.0",
    "notion":"3.0.2",
    "sublime":"4170"
}'

# Determinar pacotes a verificar
if [ -n "$GROUP" ]; then
    GROUP_FILE="/var/lib/meupkg/groups/$GROUP.txt"
    if [ ! -f "$GROUP_FILE" ]; then
        echo "Grupo '$GROUP' não encontrado!"
        exit 1
    fi
    PKGS=$(cat "$GROUP_FILE")
else
    PKGS=$(cut -d= -f1 "$INSTALLED_DB")
fi

echo "=== Pacotes com updates disponíveis ==="

for pkg in $PKGS; do
    ver_inst=$(grep "^$pkg=" "$INSTALLED_DB" | cut -d= -f2)
    ver_latest=$(echo "$LATEST_JSON" | jq -r --arg p "$pkg" '.[$p]')

    if [ -z "$ver_inst" ] || [ "$ver_latest" == "null" ] || [ "$ver_inst" == "$ver_latest" ]; then
        continue
    fi

    echo "→ $pkg: $ver_inst → $ver_latest"
    read -p "Quer atualizar $pkg? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        RECIPEDIR="/var/lib/meupkg/recipes/$pkg"
        RECIPE_FILE="$RECIPEDIR/build.sh"

        # Atualiza versão na receita
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

        # Carregar receita
        source "$RECIPE_FILE"

        # Baixar, compilar e instalar
        curl -L -o ${name}-${version}.tar.* "$url"
        rm -rf "$PKGDIR"
        mkdir -p "$PKGDIR"
        build
        install_pkg
        cp -r "$PKGDIR"/* /

        # Atualizar banco
        sed -i "/^$name=/d" "$INSTALLED_DB"
        echo "$name=$version" >> "$INSTALLED_DB"

        echo "==> $name atualizado para versão $version ✅"
    else
        echo "Pulando $pkg..."
    fi
done

echo "=== Atualizações concluídas ==="
