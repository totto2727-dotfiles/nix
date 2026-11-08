#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 || ( $# -eq 1 && $1 != --dry-run ) ]]; then
  echo 'Usage: nix run .#update -- [--dry-run]' >&2
  exit 2
fi

cat share/packages/README.md
printf '\nLocal package versions are NOT changed by flake updates. Follow the inventory above.\n'

# Refresh shared inputs before their consumers, without elevating privileges.
for flake in share/packages share/my/macos share/my macos macos-work nixos nixos-server .; do
  if [[ ${1:-} == --dry-run ]]; then
    printf 'nix flake update --flake ./%s\n' "$flake"
  else
    nix flake update --flake "./$flake"
  fi
done
