#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 || ( $# -eq 2 && $2 != --dry-run ) ]]; then
  echo 'Usage: nix run .#rebuild -- <macos|macos-work|nixos|nixos-server> [--dry-run]' >&2
  exit 2
fi

host=$1
case "$host" in
  macos) configuration=totto2727-macos; platform=Darwin ;;
  macos-work) configuration=AMADH5CQH14H3; platform=Darwin ;;
  nixos|nixos-server) configuration=nixos; platform=Linux ;;
  *) echo "Unknown host: $host" >&2; exit 2 ;;
esac

printf 'Read share/packages/README.md before upgrading. Run nix run .#update separately if needed.\n'
if [[ ${2:-} == --dry-run ]]; then
  printf 'nix run .#check\n'
  if [[ $platform == Darwin ]]; then
    printf 'sudo nix run --inputs-from ./%s nix-darwin -- switch --flake ./%s#%s\n' "$host" "$host" "$configuration"
  else
    printf 'sudo nixos-rebuild switch --flake ./%s#%s\n' "$host" "$configuration"
  fi
  exit 0
fi

if [[ $(uname -s) != "$platform" ]]; then
  echo "$host requires $platform. No changes were made." >&2
  exit 2
fi

nix run .#check
if [[ $platform == Darwin ]]; then
  sudo nix run --inputs-from "./$host" nix-darwin -- switch --flake "./$host#$configuration"
else
  sudo nixos-rebuild switch --flake "./$host#$configuration"
fi
