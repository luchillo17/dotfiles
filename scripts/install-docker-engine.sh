#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This installer only supports Debian/Ubuntu-style systems."
  exit 1
fi

if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
  echo "WSL detected. Refusing to install Docker Engine."
  echo "Use Docker Desktop for Windows with WSL integration instead."
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "Docker already installed: $(docker --version)"
else
  echo "Installing Docker Engine..."

  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg

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
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

if getent group docker >/dev/null 2>&1; then
  if id -nG "$USER" | grep -qw docker; then
    echo "$USER is already in the docker group."
  else
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "You need to log out and back in for docker group membership to take effect."
  fi
fi

sudo systemctl enable docker
sudo systemctl start docker

echo "Docker Engine setup complete."
