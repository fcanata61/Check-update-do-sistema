#!/bin/bash
# Compara versões instaladas x upstream

INSTALLED_DB="/var/lib/meupkg/installed.db"
LATEST_JSON=$(./check-updates.sh)

echo "=== Pacotes com novas versões disponíveis ==="

updates=0

while IFS='=' read -r pkg ver_inst; do
    ver_latest=$(echo "$LATEST_JSON" | jq -r --arg p "$pkg" '.[$p]')
    if [ "$ver_latest" != "null" ] && [ "$ver_latest" != "$ver_inst" ]; then
        echo "→ $pkg: $ver_inst → $ver_latest"
        updates=$((updates+1))
    fi
done < "$INSTALLED_DB"

if [ $updates -eq 0 ]; then
    echo "Tudo está atualizado. 👍"
fi
