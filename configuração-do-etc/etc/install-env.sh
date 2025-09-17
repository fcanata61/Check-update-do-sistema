#!/bin/sh
# Script para instalar configuração de ambiente global
# Modelo moderno com /etc/profile.d

set -e

echo "[*] Criando estrutura de ambiente..."

# Cria diretórios se não existirem
mkdir -p /etc/profile.d

# =========================
# /etc/profile
# =========================
cat > /etc/profile <<'EOF'
# /etc/profile - ambiente global de login

# PATH mínimo (será estendido pelos scripts em /etc/profile.d)
PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH

# Carrega variáveis simples do /etc/environment
if [ -f /etc/environment ]; then
    export $(grep -v '^#' /etc/environment | xargs)
fi

# Carrega todos os scripts modulares em /etc/profile.d
for script in /etc/profile.d/*.sh; do
    [ -r "$script" ] && . "$script"
done

# Configuração de shell interativo
if [ "$PS1" ]; then
    export PS1='\u@\h:\w \$ '
fi
EOF

# =========================
# /etc/environment
# =========================
cat > /etc/environment <<'EOF'
LANG=en_US.UTF-8
EDITOR=nano
PAGER=less
EOF

# =========================
# GCC
# =========================
cat > /etc/profile.d/01-gcc.sh <<'EOF'
# Configuração do GCC
export CC=gcc
export CXX=g++
export PATH="/usr/lib/gcc/bin:$PATH"
export MANPATH="/usr/share/gcc-data/man:$MANPATH"
EOF

# =========================
# Python
# =========================
cat > /etc/profile.d/02-python.sh <<'EOF'
# Configuração do Python
export PYTHONPATH="/usr/lib/python3.11/site-packages"
export PATH="/usr/lib/python3.11/bin:$PATH"
EOF

# =========================
# Java
# =========================
cat > /etc/profile.d/03-java.sh <<'EOF'
# Configuração do Java
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
EOF

# =========================
# Rust
# =========================
cat > /etc/profile.d/04-rust.sh <<'EOF'
# Configuração do Rust
export PATH="$HOME/.cargo/bin:$PATH"
EOF

# =========================
# Go
# =========================
cat > /etc/profile.d/05-go.sh <<'EOF'
# Configuração do Go
export GOROOT="/usr/lib/go"
export GOPATH="$HOME/go"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
EOF

# =========================
# Ruby
# =========================
cat > /etc/profile.d/06-ruby.sh <<'EOF'
# Configuração do Ruby
export PATH="/usr/lib/ruby/gems/bin:$PATH"
EOF

# =========================
# Lua
# =========================
cat > /etc/profile.d/07-lua.sh <<'EOF'
# Configuração do Lua
export LUA_PATH="/usr/share/lua/5.4/?.lua;;"
export LUA_CPATH="/usr/lib/lua/5.4/?.so;;"
EOF

# =========================
# Aliases globais
# =========================
cat > /etc/profile.d/10-aliases.sh <<'EOF'
# Aliases globais
alias ll='ls -lh --color=auto'
alias grep='grep --color=auto'
EOF

echo "[✔] Ambiente instalado com sucesso."
echo "[!] Lembre-se de rodar: source /etc/profile"
