#!/bin/sh
# Script para verificar ambiente global de compiladores e linguagens

echo "===================================="
echo "   Relatório de Ambiente do Sistema  "
echo "===================================="
echo

# Função para testar programas
check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "[✔] $1: $(command -v $1)"
        [ -n "$2" ] && $1 $2 2>/dev/null | head -n 1
    else
        echo "[✘] $1: não encontrado"
    fi
    echo
}

# --- GCC / C++ ---
check_cmd gcc "--version"
check_cmd g++ "--version"

# --- Python ---
check_cmd python3 "--version"
check_cmd pip3 "--version"

# --- Java ---
check_cmd java "-version"
check_cmd javac "-version"

# --- Rust ---
check_cmd rustc "--version"
check_cmd cargo "--version"

# --- Go ---
check_cmd go "version"

# --- Ruby ---
check_cmd ruby "--version"
check_cmd gem "--version"

# --- Lua ---
check_cmd lua "-v"

# --- PATH ---
echo "===================================="
echo "   Variáveis de Ambiente             "
echo "===================================="
echo "PATH=$PATH"
echo "JAVA_HOME=${JAVA_HOME:-não definido}"
echo "GOROOT=${GOROOT:-não definido}"
echo "GOPATH=${GOPATH:-não definido}"
echo "PYTHONPATH=${PYTHONPATH:-não definido}"
echo "LUA_PATH=${LUA_PATH:-não definido}"
echo "LUA_CPATH=${LUA_CPATH:-não definido}"
echo
