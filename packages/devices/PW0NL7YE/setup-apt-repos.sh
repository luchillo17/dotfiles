#!/usr/bin/env bash
# AI assisted development
set -euo pipefail

if [[ -f /etc/apt/sources.list.d/azure-cli.list ]] \
  || apt-cache policy azure-cli 2>/dev/null | grep -q packages.microsoft.com; then
  exit 0
fi

if ! command -v curl >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
  echo "curl and gpg are required to configure the Azure CLI apt repository."
  exit 1
fi

echo "Configuring Microsoft apt repository for azure-cli..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

distro="$(. /etc/os-release && echo "${ID:-ubuntu}")"
codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"

if [[ "$distro" != "ubuntu" && "$distro" != "debian" ]]; then
  echo "Unsupported distro for azure-cli apt repo: ${distro:-unknown}"
  exit 1
fi

if ! curl -fsSL "https://packages.microsoft.com/config/${distro}/${codename}.prod.list" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.list >/dev/null; then
  echo "Azure CLI apt repo unavailable for ${distro} ${codename}; trying jammy fallback..."
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli jammy main" \
    | sudo tee /etc/apt/sources.list.d/azure-cli.list >/dev/null
fi
