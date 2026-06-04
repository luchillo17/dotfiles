# Devices

This repository targets more than one machine. Each host is identified by:

- A **chezmoi profile** (`wsl`, `desktop`, or `server`) set in local-only chezmoi data.
- A **hostname** used to merge optional package lists under `packages/devices/<hostname>/`.

Templates and scripts read `{{ .profile }}` (and optional template data) from `~/.config/chezmoi/chezmoi.toml`, which is **not** committed.

## Package layers

`scripts/install-packages.sh` merges lists in this order (later layers can add packages; duplicates are de-duplicated):

1. `packages/common/`
2. `packages/profiles/<profile>/` when `DOTFILES_PROFILE` is set (see `run_install-packages.sh.tmpl`)
3. `packages/devices/<hostname>/` when `DOTFILES_HOSTNAME` is set (defaults to `hostname`)

Supported list files in each layer match `packages/devices/README.md` (`apt.txt`, `snap.txt`, and so on).

**In this repo right now:** `packages/common/`, `packages/profiles/desktop/`, `packages/devices/PW0NL7YE/`, and `packages/devices/ewlqemyb.vm/` exist. There are no `packages/profiles/wsl/` or `packages/profiles/server/` directories yet; add them when you want profile-specific packages for those machines—the install script will use them automatically once the folder exists and `DOTFILES_PROFILE` matches.

## Profiles

### `wsl`

Use when Ubuntu runs under WSL2 and you treat it as a dev shell with Windows providing the desktop and integrations.

- Shell: `dot_zshrc.tmpl` enables WSL-friendly defaults (for example `wslview` as `BROWSER` when available).
- Docker: `scripts/install-docker-desktop.sh` and `scripts/install-docker-engine.sh` both **detect WSL and exit without installing** Linux Docker packages. Use **Docker Desktop for Windows** with the WSL2 integration and distro enabled.

### `desktop`

Use for a full **native** Ubuntu desktop or workstation (not WSL).

- Docker: `run_onchange_install-docker-desktop.sh.tmpl` runs `scripts/install-docker-desktop.sh`, which installs **Docker Desktop for Linux** on Ubuntu when not on WSL (the script exits early under WSL).

### `server`

Use for headless VPS or server installs.

- Docker: `run_onchange_install-docker-engine.sh.tmpl` runs `scripts/install-docker-engine.sh`. On **non-WSL** Ubuntu with `apt-get`, that script installs **Docker Engine** from Docker’s apt repo when `docker` is not already present. On WSL it refuses, same as above.
- Optional chezmoi **template data** `dockerEngine` is referenced in `.chezmoiignore` for conditional ignores; per-device intent (for example “this VPS uses Engine”) is also recorded in `packages/devices/<hostname>/notes.md` where useful.

## Local chezmoi data

Configure each machine in:

`~/.config/chezmoi/chezmoi.toml`

Set `sourceDir` if your checkout is not the default, and under `[data]` set at least `profile`. Add `gitName` / `gitEmail` (or your own keys) for `dot_gitconfig.tmpl`, and any flags your templates expect.

**Example — WSL dev machine**

```toml
[data]
profile = "wsl"
gitName = "Your Name"
gitEmail = "you@example.com"
```

**Example — VPS**

```toml
[data]
profile = "server"
gitName = "Your Name"
gitEmail = "you@example.com"
dockerEngine = true
```

## Known devices

Per-host details (provider, access notes, Docker intent) should stay in **`packages/devices/<hostname>/notes.md`** so this file stays a short index.

| Hostname          | Profile  | Notes                                                        |
| ----------------- | -------- | ------------------------------------------------------------ |
| `DESKTOP-LL0IH7K` | `wsl`    | WSL2 Ubuntu dev shell; Docker via Docker Desktop on Windows. |
| `PW0NL7YE`        | `wsl`    | WSL2 Ubuntu dev shell; Docker via Docker Desktop on Windows. |
| `ewlqemyb.vm`     | `server` | See `packages/devices/ewlqemyb.vm/notes.md`.                 |

Do not commit secrets, private keys, provider credentials, client or employer names, client data, or sensitive infrastructure in device notes.

## Device-specific packages

Use `packages/devices/<hostname>/` only for packages that **must** be limited to one machine. Prefer:

- `packages/common/` for everywhere
- `packages/profiles/<profile>/` for everything with that profile (once those directories exist)

See `packages/devices/README.md` for the expected file layout.
