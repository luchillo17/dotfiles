#!/usr/bin/env bash
# AI assisted development
set -euo pipefail

if command -v gitkraken >/dev/null 2>&1 \
  || dpkg-query -W -f='${Status}' gitkraken 2>/dev/null | grep -q "install ok installed"; then
  echo "GitKraken already installed."
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. Skipping GitKraken install."
  exit 0
fi

arch="$(dpkg --print-architecture)"
if [[ "$arch" != "amd64" ]]; then
  echo "GitKraken .deb install supports amd64 only; skipping on ${arch}."
  exit 0
fi

deb_url="https://release.gitkraken.com/linux/gitkraken-amd64.deb"
tmp_deb="$(mktemp /tmp/gitkraken.XXXXXX.deb)"
trap 'rm -f "$tmp_deb"' EXIT

echo "Downloading GitKraken..."
curl -fsSL "$deb_url" -o "$tmp_deb"

echo "Installing GitKraken..."
sudo apt-get update
if ! sudo apt-get install -y "$tmp_deb"; then
  sudo apt-get install -fy
  sudo apt-get install -y "$tmp_deb"
fi

echo "GitKraken installed."
