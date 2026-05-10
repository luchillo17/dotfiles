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

## Docker

This device opts into Docker Engine through local chezmoi data:

```ini
dockerEngine = true
```

Docker Engine is not part of the generic server profile.
