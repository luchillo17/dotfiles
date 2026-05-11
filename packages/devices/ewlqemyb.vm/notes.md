# ewlqemyb.vm

LightNode VPS.

## Profile

server

## Access

Local SSH alias: lightnode

Do not commit private keys, provider credentials, IP-sensitive notes, or secrets.

## OS

Ubuntu 22.04.5 LTS.

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

## Secrets

This device uses LastPass for deployment secrets.

Marker:

- packages/devices/ewlqemyb.vm/secrets-provider.lastpass.enabled

Required package:

- lastpass-cli

Real secrets stay in LastPass and are not committed to this repository.
