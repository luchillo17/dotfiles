# Secrets

This repository must not contain real secrets.

## Policy

Track templates, examples, provider markers, and scripts.

Do not commit:

- real `.env` files
- database passwords
- app keys
- API tokens
- private SSH keys
- password manager exports
- provider credentials
- client data

## Device provider markers

A device declares its secrets provider with one marker file under:

packages/devices/<hostname>/

Supported markers:

- secrets-provider.lastpass.enabled
- secrets-provider.1password.enabled
- secrets-provider.env.enabled

Only one provider marker should be active per device.

## Secret retrieval

Use:

scripts/secret-get.sh <app> <key>

Examples:

scripts/secret-get.sh firefly-iii APP_KEY
scripts/secret-get.sh firefly-iii DB_PASSWORD
scripts/secret-get.sh homebox SMTP_PASSWORD

## LastPass convention

Treat each LastPass secure note as a remote **`.env`**: one note per app at **`dotfiles/<app>`** (folder `dotfiles`, name `<app>`), body is **`KEY=value`** lines the same way as a `.env` file.

## 1Password convention

1Password item path:

op://<vault>/dotfiles-<app>/<KEY>

Default vault:

Private

Example:

op://Private/dotfiles-firefly-iii/APP_KEY

## Environment fallback

The `env` provider maps:

<app> + <key>

to an uppercase environment variable.

Example:

firefly-iii APP_KEY

becomes:

FIREFLY_III_APP_KEY

## Application secrets

Firefly III requires secrets such as:

- APP_KEY
- DB_PASSWORD
- database user passwords
- cron token if cron is enabled
- SMTP password if mail is enabled

Homebox basic deployment may not need secrets, but SMTP or integrations may require them.

## Local server files

Real generated secret files should live only on the server, for example:

~/apps/firefly-iii/.env
~/apps/firefly-iii/.db.env
~/apps/homebox/.env

These files are not committed.
