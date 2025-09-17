#!/bin/sh
# Clona seu repo e cria ambiente de teste em VM/Container

git clone https://meu-repo-git.local/meu-sistema stage3
cd stage3

# Muda para branch de teste
git checkout -b testing

echo "Ambiente de teste (Stage3) criado em ./stage3"
