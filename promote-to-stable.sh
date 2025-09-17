#!/bin/sh
# Promove pacotes testados da VM Stage3 para branch stable

cd stage3 || exit 1

# Garante que estamos na branch de teste
git checkout testing
git pull origin testing

# Volta para stable
git checkout stable
git merge testing

# Marca versão com tag
DATE=$(date +%Y-%m-%d)
git tag "release-$DATE"

git push origin stable --tags

echo "Updates promovidos para stable e tag criados."
