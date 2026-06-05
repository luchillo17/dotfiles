#!/usr/bin/env bash
# AI assisted development
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"

PROFILE="${DOTFILES_PROFILE:-}"
HOSTNAME_VALUE="${DOTFILES_HOSTNAME:-$(hostname 2>/dev/null || true)}"

LAYERS=(
  "$PACKAGES_DIR/common"
)

if [[ -n "$PROFILE" ]]; then
  LAYERS+=("$PACKAGES_DIR/profiles/$PROFILE")
fi

if [[ -n "$HOSTNAME_VALUE" ]]; then
  LAYERS+=("$PACKAGES_DIR/devices/$HOSTNAME_VALUE")
fi

read_package_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  grep -vE '^\s*(#|$)' "$file" || true
}

collect_packages() {
  local filename="$1"

  for layer in "${LAYERS[@]}"; do
    read_package_file "$layer/$filename"
  done | sort -u
}

is_apt_package_installed() {
  local package="$1"
  dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"
}

run_device_apt_repo_setup() {
  local script="$PACKAGES_DIR/devices/$HOSTNAME_VALUE/setup-apt-repos.sh"

  if [[ -z "$HOSTNAME_VALUE" || ! -f "$script" ]]; then
    return 0
  fi

  echo "Running device apt repo setup: $script"
  bash "$script"
}

install_apt_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Skipping apt packages: apt-get not found."
    return 0
  fi

  mapfile -t packages < <(collect_packages "apt.txt")

  if [[ "${#packages[@]}" -eq 0 ]]; then
    echo "No apt packages configured."
    return 0
  fi

  local missing=()

  for package in "${packages[@]}"; do
    if ! is_apt_package_installed "$package"; then
      missing+=("$package")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    echo "All apt packages are already installed."
    return 0
  fi

  echo "Installing missing apt packages:"
  printf '  %s\n' "${missing[@]}"

  run_device_apt_repo_setup

  sudo apt-get update
  sudo apt-get install -y "${missing[@]}"
}

run_profile_package_extras() {
  if [[ -z "$PROFILE" ]]; then
    return 0
  fi

  local script="$PACKAGES_DIR/profiles/$PROFILE/install-packages.sh"

  if [[ ! -f "$script" ]]; then
    return 0
  fi

  echo "Running profile package extras: $script"
  bash "$script"
}

echo "Installing packages from layered package lists"
echo "Profile: ${PROFILE:-none}"
echo "Hostname: ${HOSTNAME_VALUE:-none}"
echo

install_apt_packages

run_profile_package_extras

echo
echo "Package installation complete."
