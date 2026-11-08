#!/usr/bin/env bash
set -euo pipefail

git ls-files --cached --others --exclude-standard -z -- '*.nix' | xargs -0 nixfmt --check
bash tasks/test.sh

for flake in . share/packages share/my share/my/macos macos macos-work nixos nixos-server; do
  nix flake check --all-systems --no-build --no-update-lock-file "./$flake"
done

# Nix does not validate the non-standard darwinConfigurations output.
nix eval --no-update-lock-file --raw './macos#darwinConfigurations.totto2727-macos.system.drvPath'
printf '\n'
nix eval --no-update-lock-file --raw './macos-work#darwinConfigurations.AMADH5CQH14H3.system.drvPath'
printf '\n'
