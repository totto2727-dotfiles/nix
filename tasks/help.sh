#!/usr/bin/env bash
set -euo pipefail

cat <<'HELP'
Run these commands from the repository root:
  nix run .#check                        Format check, task tests, flake evaluation only
  nix run .#fix                          Format Nix files
  nix run .#update -- --dry-run           Preview all flake input updates
  nix run .#update                       Read the inventory and update all flake inputs
  nix run .#rebuild -- HOST --dry-run     Preview a host switch without changing anything
  nix run .#rebuild -- HOST               Check and switch an existing host

Hosts: macos, macos-work, nixos, nixos-server
Read share/packages/README.md before any dependency update or system upgrade.
Local package versions need the manual update steps in that inventory.
HELP
