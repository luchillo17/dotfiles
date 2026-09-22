#!/usr/bin/env bash
# Ensure the VS Code inotify watch limit. Do not lower a higher value.
# https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
set -euo pipefail

min_value="524288"
# Load after /etc/sysctl.d/99-sysctl.conf (symlink to /etc/sysctl.conf).
conf="/etc/sysctl.d/99-zzz-inotify-watches.conf"

max_persistent=0
shopt -s nullglob
for file in /etc/sysctl.conf /etc/sysctl.d/*.conf; do
  if [[ "$file" == "$conf" ]]; then
    continue
  fi
  while IFS= read -r value; do
    if [[ "$value" =~ ^[0-9]+$ && "$value" -gt "$max_persistent" ]]; then
      max_persistent="$value"
    fi
  done < <(sed -n 's/^fs\.inotify\.max_user_watches=//p' "$file")
done
shopt -u nullglob

live="$(cat /proc/sys/fs/inotify/max_user_watches)"

if [[ "$max_persistent" -ge "$min_value" ]]; then
  if [[ -f "$conf" ]]; then
    sudo rm -f "$conf"
  fi
  if [[ "$live" -lt "$min_value" ]]; then
    sudo sysctl -q -w "fs.inotify.max_user_watches=${max_persistent}"
    live="$(cat /proc/sys/fs/inotify/max_user_watches)"
  fi
  echo "fs.inotify.max_user_watches=${live} (persistent ${max_persistent}, minimum ${min_value})"
  exit 0
fi

desired_conf="$(printf '%s\n' \
  "# VS Code file watcher limit (error ENOSPC)." \
  "# https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc" \
  "fs.inotify.max_user_watches=${min_value}")"

current_conf=""
if [[ -f "$conf" ]]; then
  current_conf="$(cat "$conf")"
fi

if [[ "$current_conf" != "$desired_conf" || "$live" -lt "$min_value" ]]; then
  if [[ "$current_conf" != "$desired_conf" ]]; then
    printf '%s\n' "$desired_conf" | sudo tee "$conf" >/dev/null
  fi
  sudo sysctl -q --system
  live="$(cat /proc/sys/fs/inotify/max_user_watches)"
fi

if [[ "$live" -lt "$min_value" ]]; then
  echo "fs.inotify.max_user_watches is ${live}, expected at least ${min_value}." >&2
  exit 1
fi

echo "fs.inotify.max_user_watches=${live}"
