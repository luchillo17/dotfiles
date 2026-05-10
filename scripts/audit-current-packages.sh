#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOSTNAME="$(hostname)"
OUTPUT_DIR="$ROOT_DIR/tmp/package-audit/$HOSTNAME"

mkdir -p "$OUTPUT_DIR"

echo "Writing package audit to: $OUTPUT_DIR"
echo "This is an audit only. Do not treat it as desired state without review."

if command -v apt-mark >/dev/null 2>&1; then
  apt-mark showmanual | sort > "$OUTPUT_DIR/apt.txt"
  echo "Wrote apt.txt"
fi

if command -v snap >/dev/null 2>&1; then
  snap list | awk 'NR > 1 {print $1}' | sort > "$OUTPUT_DIR/snap.txt"
  echo "Wrote snap.txt"
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application 2>/dev/null | sort > "$OUTPUT_DIR/flatpak.txt"
  echo "Wrote flatpak.txt"
fi

if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --parseable 2>/dev/null \
    | sed '1d' \
    | xargs -r -n1 basename \
    | sort > "$OUTPUT_DIR/npm-global.txt"
  echo "Wrote npm-global.txt"
fi

if command -v pipx >/dev/null 2>&1; then
  pipx list --short 2>/dev/null \
    | awk '{print $1}' \
    | sort > "$OUTPUT_DIR/pipx.txt"
  echo "Wrote pipx.txt"
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --list 2>/dev/null \
    | grep -E '^[a-zA-Z0-9_-]+ v[0-9]' \
    | awk '{print $1}' \
    | sort > "$OUTPUT_DIR/cargo.txt"
  echo "Wrote cargo.txt"
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions 2>/dev/null | sort > "$OUTPUT_DIR/vscode-extensions.txt"
  echo "Wrote vscode-extensions.txt"
fi

if command -v cursor >/dev/null 2>&1; then
  cursor --list-extensions 2>/dev/null | sort > "$OUTPUT_DIR/cursor-extensions.txt"
  echo "Wrote cursor-extensions.txt"
fi

echo "Done."
echo
echo "Review files under:"
echo "$OUTPUT_DIR"
echo
echo "Promote intentional packages manually into:"
echo "- packages/common/"
echo "- packages/profiles/desktop/"
echo "- packages/profiles/server/"
echo "- packages/devices/<hostname>/"
