# Dotfiles

Modern Ubuntu development environment setup for `luchillo17`.

This settings, shell setup, and development environment conventions.This repository is the source of truth for intentional configuration needed to make a new Ubuntu machine productive quickly without syncing an entire home directory.

It does not replace backups, personal file sync, password managers, or project-specific dependency management.

## Goals

- Reproduce a productive Ubuntu development environment across devices.
- Track intentional configuration in Git.
- Keep machine setup understandable and auditable.
- Support multiple machines with slightly different needs.
- Prefer declarative/package-list based setup where possible.
- Keep secrets, personal data, caches, and generated state out of Git.

## Non-goals

This repository is not for:

- Full home directory synchronization.
- Full system backups.
- Personal documents.
- Browser profiles.
- Application caches.
- Secrets or credentials.
- Project dependency folders such as `node_modules`.
- Python virtual environments.
- Build artifacts.
- Replacing Docker, Dev Containers, or project-specific setup.

## Target system

Primary target:

- Ubuntu LTS

Other Linux distributions may work partially, but they are not the primary target.

## Main tools

This setup is built around:

- `chezmoi` for dotfile management.
- `mise` for language and runtime versions.
- Docker, Docker Compose, and Dev Containers for project-specific environments.
- Syncthing or cloud sync for personal files.
- `restic`, Borg, Timeshift, or similar tools for backups.
- A password manager or encrypted files for secrets.

## Fresh machine setup

Install basic dependencies first:

```bash
sudo apt update
sudo apt install -y git curl ca-certificates
```

Install and initialize with `chezmoi`:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply luchillo17
```

Then run the bootstrap script:

```bash
~/.local/share/chezmoi/scripts/bootstrap.sh
```

Review scripts before running them on a new machine.

## Daily chezmoi usage

Edit a managed file:

```bash
chezmoi edit ~/.zshrc
```

See pending changes:

```bash
chezmoi diff
```

Apply changes:

```bash
chezmoi apply
```

Add an existing file to chezmoi:

```bash
chezmoi add ~/.gitconfig
```

Open the source directory:

```bash
chezmoi cd
```

Commit changes:

```bash
git status
git add .
git commit -m "Update dotfiles"
git push
```

Update a machine from the repo:

```bash
chezmoi update
```

## Repository layout

```text
dotfiles/
├── README.md
├── LICENSE
├── .gitignore
├── packages/
│   ├── apt.txt
│   ├── snap.txt
│   ├── flatpak.txt
│   ├── npm-global.txt
│   ├── pipx.txt
│   ├── cargo.txt
│   ├── vscode-extensions.txt
│   └── cursor-extensions.txt
├── scripts/
│   ├── bootstrap.sh
│   ├── install-packages.sh
│   ├── install-dev-tools.sh
│   ├── install-docker.sh
│   ├── install-mise.sh
│   ├── configure-gnome.sh
│   └── backup-package-lists.sh
└── docs/
    ├── devices.md
    ├── conventions.md
    ├── secrets.md
    ├── editor.md
    └── troubleshooting.md
```

Chezmoi-managed files should use chezmoi naming conventions, for example:

```text
dot_zshrc
dot_gitconfig.tmpl
dot_tmux.conf
dot_config/
private_dot_ssh/
executable_dot_local/bin/
run_once_*.sh
run_onchange_*.sh
```

## What belongs in this repo

Track intentional configuration, including:

- Shell configuration.
- Git configuration.
- Tmux configuration.
- Terminal configuration.
- Neovim configuration.
- VS Code and Cursor settings.
- Cursor rules.
- MCP configuration templates.
- EditorConfig.
- Git attributes.
- Package lists.
- Bootstrap scripts.
- Local helper scripts.
- GNOME/Ubuntu preferences.
- Device setup notes.
- Safe templates and examples.

## What does not belong in this repo

Do not commit:

- SSH private keys.
- API tokens.
- GitHub, GitLab, npm, or cloud tokens.
- Cloud credentials.
- Database credentials.
- Real `.env` files.
- Password manager exports.
- Browser profiles.
- App caches.
- `node_modules`.
- Python virtual environments.
- Build artifacts.
- Large binary files.
- Downloaded installers.
- Personal documents.
- Private client data.

## Gitignore policy

The policy is:

> Ignore generated state and secrets. Track intentional configuration.

Editor and project configuration should not be ignored by default.

This repo may intentionally track files and directories such as:

```text
.vscode/
.cursor/
.editorconfig
.gitattributes
```

Generated state, local machine state, caches, credentials, and dependency folders should be ignored.

## Editor configuration policy

Editor configuration is considered intentional configuration when it defines workflow, tooling, project behavior, or team conventions.

The following are allowed when safe:

- `.vscode/settings.json`
- `.vscode/extensions.json`
- `.cursor/`
- Cursor rules.
- MCP configuration templates.
- `.editorconfig`
- `.gitattributes`

Do not commit editor files that contain secrets, machine-specific absolute paths, private workspace state, or personal/client data.

Use templates or examples for sensitive editor/tool configuration:

```text
mcp.json.tmpl
mcp.example.json
.env.example
```

## Secrets policy

Secrets must not be committed directly.

Use one of these approaches instead:

- Password manager.
- Environment variables.
- `chezmoi` templates with external secret lookups.
- Encrypted files, if explicitly intended.
- `.env.example` files for documentation only.

Real `.env` files should stay local and ignored.

Safe examples:

```text
.env.example
mcp.example.json
dot_gitconfig.tmpl
```

Unsafe examples:

```text
.env
id_rsa
github_token.txt
npmrc_with_token
cloud-credentials.json
```

## Package and runtime strategy

Package lists are organized by scope under `packages/`.

The package model is layered:

- `packages/common/`: packages intended for every machine.
- `packages/profiles/desktop/`: packages intended for Ubuntu desktop/workstation machines.
- `packages/profiles/server/`: packages intended for VPS/headless server machines.
- `packages/devices/`: packages intended for one specific hostname.

A machine should be configured from these layers:

- common
- selected profile
- optional device-specific additions

Examples:

- Ubuntu desktop development machine: common + desktop + device-specific additions.
- VPS server: common + server + device-specific additions.

Package files may include:

- `apt.txt`
- `snap.txt`
- `flatpak.txt`
- `npm-global.txt`
- `pipx.txt`
- `cargo.txt`
- `vscode-extensions.txt`
- `cursor-extensions.txt`

Package lists should be curated intent, not raw snapshots of the current machine.

Language and runtime versions should be managed with `mise`.

Use:

- `mise` for Node, Python, Go, Rust, Bun, and similar runtimes.
- Docker and Dev Containers for project-specific services and environments.
- Package lists for global tools that are intentionally installed on development machines.

Project-specific dependencies should stay in each project, not in this repo.

Avoid using this repo to install project dependencies globally.

## Sync vs backup separation

This repo is only for intentional configuration.

Use separate tools for other concerns:

- Dotfiles/configuration: this repository and `chezmoi`.
- Personal file sync: Syncthing, cloud sync, or similar.
- Backups: `restic`, Borg, Timeshift, or similar.
- Secrets: password manager or encrypted secret storage.
- Project environments: Docker, Docker Compose, Dev Containers, and project-local setup.

## License

See `LICENSE.md`.
