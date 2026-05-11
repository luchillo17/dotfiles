#!/usr/bin/env bash
set -euo pipefail

APP_NAME="firefly-iii"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SECRET_GET="${DOTFILES_SECRET_GET:-$HOME/.local/share/chezmoi/scripts/secret-get.sh}"

ENV_FILE="$SCRIPT_DIR/.env"
DB_ENV_FILE="$SCRIPT_DIR/.db.env"

get_secret() {
  "$SECRET_GET" "$APP_NAME" "$1"
}

APP_KEY="$(get_secret APP_KEY)"
DB_PASSWORD="$(get_secret DB_PASSWORD)"
MYSQL_ROOT_PASSWORD="$(get_secret MYSQL_ROOT_PASSWORD)"
STATIC_CRON_TOKEN="$(get_secret STATIC_CRON_TOKEN)"

cat > "$ENV_FILE" <<EOF_ENV
APP_ENV=production
APP_DEBUG=false
SITE_OWNER=${FIREFLY_III_SITE_OWNER:-luchillo17@gmail.com}
APP_KEY=$APP_KEY
DEFAULT_LANGUAGE=en_US
DEFAULT_LOCALE=equal
TZ=${TZ:-America/Bogota}
TRUSTED_PROXIES=**

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=firefly
DB_USERNAME=firefly
DB_PASSWORD=$DB_PASSWORD

STATIC_CRON_TOKEN=$STATIC_CRON_TOKEN

APP_URL=${FIREFLY_III_APP_URL:-http://localhost:8080}
EOF_ENV

cat > "$DB_ENV_FILE" <<EOF_DB
MYSQL_RANDOM_ROOT_PASSWORD=false
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=firefly
MYSQL_USER=firefly
MYSQL_PASSWORD=$DB_PASSWORD
EOF_DB

chmod 600 "$ENV_FILE" "$DB_ENV_FILE"

echo "Generated:"
echo "$ENV_FILE"
echo "$DB_ENV_FILE"
