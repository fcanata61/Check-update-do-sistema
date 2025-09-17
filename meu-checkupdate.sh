#!/bin/bash
GROUP=$1
INSTALLED_DB="/var/lib/meupkg/installed.db"

# JSON simulado de versão upstream (normalmente buscaria via curl/git)
LATEST_JSON='{
    "vim":"9.1.0790",
    "xorg-server":"21.1.13",
    "firefox":"132.0",
    "chromium":"130.0.6700.0",
    "notion":"3.0.2",
    "sublime":"4170"
}'

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

updates=0
for pkg in $PKGS; do
    ver_inst=$(grep "^$pkg=" "$INSTALLED_DB" | cut -d= -f2)
    ver_latest=$(echo "$LATEST_JSON" | jq -r --arg p "$pkg" '.[$p]')
    if [ "$ver_latest" != "null" ] && [ "$ver_inst" != "$ver_latest" ]; then
        echo "→ $pkg: $ver_inst → $ver_latest"
        updates=$((updates+1))
    fi
done

[ $updates -eq 0 ] && echo "Tudo está atualizado. 👍"
