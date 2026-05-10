# Device-specific packages

Use this directory for packages that are intentionally installed only on one specific machine.

Prefer shared packages in:

- packages/common/
- packages/profiles/desktop/
- packages/profiles/server/

Device-specific package lists should stay small and intentional.

Example structure:

packages/devices/my-hostname/
├── apt.txt
├── snap.txt
├── flatpak.txt
├── npm-global.txt
├── pipx.txt
├── cargo.txt
├── vscode-extensions.txt
└── cursor-extensions.txt
