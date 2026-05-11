#!/usr/bin/env bash
set -euo pipefail

APP="${1:?Usage: secret-get.sh <app> <key>}"
KEY="${2:?Usage: secret-get.sh <app> <key>}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOSTNAME_VALUE="${DOTFILES_HOSTNAME:-$(hostname 2>/dev/null || true)}"
DEVICE_DIR="$ROOT_DIR/packages/devices/$HOSTNAME_VALUE"

detect_provider() {
  if [[ -n "${DOTFILES_SECRETS_PROVIDER:-}" ]]; then
    printf '%s\n' "$DOTFILES_SECRETS_PROVIDER"
    return 0
  fi

  if [[ -f "$DEVICE_DIR/secrets-provider.lastpass.enabled" ]]; then
    printf '%s\n' "lastpass"
    return 0
  fi

  if [[ -f "$DEVICE_DIR/secrets-provider.1password.enabled" ]]; then
    printf '%s\n' "1password"
    return 0
  fi

  if [[ -f "$DEVICE_DIR/secrets-provider.env.enabled" ]]; then
    printf '%s\n' "env"
    return 0
  fi

  echo "No secrets provider configured for hostname: ${HOSTNAME_VALUE:-unknown}" >&2
  echo "Expected one provider marker under: $DEVICE_DIR" >&2
  exit 1
}

PROVIDER="$(detect_provider)"

case "$PROVIDER" in
  lastpass)
    if ! command -v lpass >/dev/null 2>&1; then
      echo "Missing LastPass CLI: lpass" >&2
      exit 1
    fi

    ITEM="dotfiles/$APP"

    if VALUE="$(lpass show --field "$KEY" "$ITEM" 2>/dev/null)"; then
      if [[ -n "$VALUE" ]]; then
        printf '%s\n' "$VALUE"
        exit 0
      fi
    fi

    if VALUE="$(lpass show --notes "$ITEM" \
      | awk -v key="$KEY" '
          index($0, key "=") == 1 {
            sub("^[^=]*=", "")
            print
            found = 1
            exit
          }
          END {
            if (!found) exit 1
          }
        ')"; then
      printf '%s\n' "$VALUE"
      exit 0
    fi

    echo "Missing secret '$KEY' in LastPass item '$ITEM'." >&2
    echo "Expected either a custom field named '$KEY' or a note line like:" >&2
    echo "$KEY=value" >&2
    exit 1
    ;;

  1password|onepassword)
    if ! command -v op >/dev/null 2>&1; then
      echo "Missing 1Password CLI: op" >&2
      exit 1
    fi

    VAULT="${DOTFILES_1PASSWORD_VAULT:-Private}"
    op read "op://$VAULT/dotfiles-$APP/$KEY"
    ;;

  env)
    ENV_KEY="$(printf '%s_%s' "$APP" "$KEY" | tr '[:lower:]-' '[:upper:]_')"

    if [[ -z "${!ENV_KEY:-}" ]]; then
      echo "Missing environment variable: $ENV_KEY" >&2
      exit 1
    fi

    printf '%s\n' "${!ENV_KEY}"
    ;;

  *)
    echo "Unsupported secrets provider: $PROVIDER" >&2
    echo "Supported: lastpass, 1password, env" >&2
    exit 1
    ;;
esac
