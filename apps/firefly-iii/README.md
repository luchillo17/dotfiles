# Firefly III

Self-hosted Firefly III deployment.

## Tracked files

- compose.yml
- env.example
- db.env.example
- generate-env.sh
- README.md

## Local files not committed

- .env
- .db.env

## Secrets

Secrets are retrieved through:

scripts/secret-get.sh firefly-iii <KEY>

Required LastPass note:

dotfiles/firefly-iii

Required note body keys:

APP_KEY=...
DB_PASSWORD=...
MYSQL_ROOT_PASSWORD=...

## Deploy on server

From the server app directory:

./generate-env.sh
docker compose up -d

## Notes

Real secrets are never committed.
