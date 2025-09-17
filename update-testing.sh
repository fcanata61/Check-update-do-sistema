#!/bin/sh
# Atualiza pacotes na branch de teste (VM Stage3)

cd stage3 || exit 1

# Lista pacotes críticos/apps a testar
echo "Rodando updates de teste..."
./meupkg.sh upgrade --group runtimes
./meupkg.sh upgrade --group apps

# Commit das receitas atualizadas
git add recipes/ installed.db
git commit -m "Updates testados no Stage3"
