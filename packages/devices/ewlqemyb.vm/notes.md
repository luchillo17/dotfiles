# ewlqemyb.vm

LightNode VPS.

## Profile

server

## Access

Local SSH alias: lightnode

Do not commit private keys, provider credentials, IP-sensitive notes, or secrets.

## OS

Ubuntu 26.04 LTS.

## Package policy

This device uses the layered package model:

- packages/common/
- packages/profiles/server/
- packages/devices/ewlqemyb.vm/

Keep this device package list small and intentional.

## Docker Engine

This device intentionally installs Docker Engine.

The opt-in marker is:

packages/devices/ewlqemyb.vm/docker-engine.enabled

Docker Engine is device-specific here, not part of the generic server profile.

## Secrets provider

This device declares its secrets provider through a marker file under:

packages/devices/ewlqemyb.vm/

Supported marker examples:

- secrets-provider.lastpass.enabled
- secrets-provider.1password.enabled
- secrets-provider.env.enabled

Real secrets are not committed to this repository.
