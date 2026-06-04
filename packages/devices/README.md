# Device-specific packages

Use this directory for packages that are intentionally installed only on one specific machine.

Prefer shared packages in:

- packages/common/
- packages/profiles/desktop/
- packages/profiles/server/

Device-specific package lists should stay small and intentional.

Do not document client names, employers, or other identifying context in this repository. Keep that in local-only notes if needed.

Example structure:

packages/devices/my-hostname/
├── apt.txt
├── setup-apt-repos.sh
├── snap.txt
├── flatpak.txt
├── npm-global.txt
├── pipx.txt
├── cargo.txt
├── vscode-extensions.txt
└── cursor-extensions.txt

Optional `setup-apt-repos.sh` runs before apt installs on that device only, when missing packages need to be installed. Use it for third-party apt sources that are not in default Ubuntu repositories.
