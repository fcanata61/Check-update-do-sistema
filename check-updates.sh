#!/bin/bash
# check-updates.sh - verifica versões upstream

echo "{"

# Xorg
XORG=$(curl -s https://www.x.org/releases/individual/xserver/ | grep -oP 'xorg-server-\K[0-9.]+(?=\.tar\.xz)' | sort -V | tail -1)
echo "\"xorg\": \"$XORG\","

# Kernel
KERNEL=$(curl -s https://www.kernel.org/ | grep -m1 -oP '(?<=strong>)[0-9]+\.[0-9]+\.[0-9]+')
echo "\"kernel\": \"$KERNEL\","

# GCC
GCC=$(curl -s https://ftp.gnu.org/gnu/gcc/ | grep -oP 'gcc-\K[0-9.]+(?=/")' | sort -V | tail -1)
echo "\"gcc\": \"$GCC\","

# Binutils
BINUTILS=$(curl -s https://ftp.gnu.org/gnu/binutils/ | grep -oP 'binutils-\K[0-9.]+(?=\.tar)' | sort -V | tail -1)
echo "\"binutils\": \"$BINUTILS\","

# Glibc
GLIBC=$(curl -s https://ftp.gnu.org/gnu/libc/ | grep -oP 'glibc-\K[0-9.]+(?=\.tar)' | sort -V | tail -1)
echo "\"glibc\": \"$GLIBC\","

# Firefox
FIREFOX=$(curl -s https://product-details.mozilla.org/1.0/firefox_versions.json | jq -r '.LATEST_FIREFOX_VERSION')
echo "\"firefox\": \"$FIREFOX\","

# Chromium
CHROMIUM=$(curl -s https://commondatastorage.googleapis.com/chromium-browser-official/ | grep -oP 'chromium-\K[0-9.]+(?=\.tar\.xz)' | sort -V | tail -1)
echo "\"chromium\": \"$CHROMIUM\","

# Google Chrome
CHROME=$(curl -s https://omahaproxy.appspot.com/all.json | jq -r '.[] | select(.os=="linux") | .versions[] | select(.channel=="stable") | .current_version' | head -1)
echo "\"chrome\": \"$CHROME\","

# Notion
NOTION=$(curl -s https://www.notion.so/desktop | grep -oP 'Notion-\K[0-9.]+(?=-x86_64\.AppImage)' | sort -V | tail -1)
echo "\"notion\": \"$NOTION\","

# Vim
VIM=$(curl -s https://api.github.com/repos/vim/vim/tags | jq -r '.[0].name')
echo "\"vim\": \"$VIM\","

# Sublime Text
SUBLIME=$(curl -s https://www.sublimetext.com/updates | grep -oP '"latest_version": "\K[0-9.]+' | head -1)
echo "\"sublime\": \"$SUBLIME\""

echo "}"
