#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Docker Desktop Linux installer only supports Linux."
  exit 0
fi

if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
  echo "WSL detected. Skipping Docker Desktop for Linux."
  echo "Use Docker Desktop for Windows with WSL integration instead."
  exit 0
fi

if command -v docker >/dev/null 2>&1 && systemctl --user status docker-desktop >/dev/null 2>&1; then
  echo "Docker Desktop appears to already be installed."
  docker --version || true
  exit 0
fi

echo "Installing Docker Desktop prerequisites..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg gnome-terminal

sudo install -m 0755 -d /etc/apt/keyrings

if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

. /etc/os-release

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update

TMP_DEB="$(mktemp --suffix=.deb)"

echo "Download the latest Docker Desktop .deb manually from:"
echo "https://docs.docker.com/desktop/setup/install/linux/ubuntu/"
echo
echo "Then install it with:"
echo "sudo apt install ./docker-desktop-amd64.deb"
echo
echo "This script intentionally stops before downloading the .deb because Docker Desktop's latest package URL/version changes."
echo "Keeping the download manual avoids pinning a stale package URL in dotfiles."
