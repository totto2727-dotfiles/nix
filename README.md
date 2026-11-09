# Nix system configurations

This repository contains the Nix configuration moved from `totto2727-org/monorepo` at commit `441b9a17bbc93f3e34582f4b1f14bf96fb056124`.
The former `nix/` directory is now the repository root.
Host definitions, package placement, flake locks, and existing Just recipes retain the source behavior.
The sandbox configuration is excluded.
The separately requested custom-package updates from commit `820ebf8e9d920b50239a4d1436d07d6dcbc9b14c` and their update inventory are retained.

## Development environment

Clone this repository and enter the pinned development shell:

```bash
git clone https://github.com/totto2727-dotfiles/nix.git
cd nix
nix develop
```

The root flake provides `nixfmt` and `just` using the nixpkgs revision inherited from the monorepo development flake.
With direnv and nix-direnv installed, run `direnv allow` to use the included `.envrc` instead.
No system configuration is activated when entering this shell.

## Operations

Run the existing recipes from the repository root inside the development shell:

```bash
just --list
just rebuild-macos
```

Use the matching `rebuild-macos-work`, `rebuild-nixos`, or `rebuild-nixos-server` recipe for the other hosts.
Host directories also retain their original Justfiles and manual setup recipes.
Read [the update inventory](share/packages/README.md) before any dependency update or system upgrade.

## Validation

CI runs on push and pull requests and checks Nix formatting with `nixfmt` from the root development flake.
The `check` job is required before merging into `main`, including pull requests from forks.
Run the same check locally with `nix develop --no-update-lock-file --command nixfmt --check $(find . -name '*.nix')`.
It does not build packages or systems, activate hosts, or change dependencies.
This migration does not repair existing evaluation or build failures, replace package choices, or update host lock files.
