# Nix system configurations

This repository is for maintainers of the personal and work macOS hosts and the NixOS desktop and server.
It is an independent Nix repository, imported from the `nix/` directory of `totto2727-org/monorepo` at commit `820ebf8e9d920b50239a4d1436d07d6dcbc9b14c`.
The imported directory is now the repository root.

## Requirements

Install Nix with flakes and the `nix-command` feature enabled.
Use [Determinate Nix](https://docs.determinate.systems/) where required by the host configuration.
Git is needed to clone and maintain the repository.
Repository commands use native Nix apps and do not require JavaScript, Node.js, pnpm, Vite+ (`vp`), Just, or Task.
Workstation applications can have their own runtime requirements.
There is no sandbox configuration.

## Commands

Run all commands from the repository root.

| Command | Purpose |
| --- | --- |
| `nix run .#check` | Check Nix formatting and evaluate all flakes without building system configurations. |
| `nix run .#fix` | Format Nix files. |
| `nix run .#update` | Print the update inventory and update all flake inputs. |
| `nix run .#rebuild -- <target>` | Build and activate the selected host configuration. |
| `nix run .#rebuild -- macos --dry-run` | Preview the rebuild command without updating lock files, building, or activating the host. |

The rebuild targets are `macos`, `macos-work`, `nixos`, and `nixos-server`.
Run a rebuild on the corresponding host.
The rebuild app does not update lock files automatically.
It runs checks without elevation, then uses `sudo` for the official host rebuild and switch command.
That platform command can build the configuration before activation.
The dry-run preview does not make configuration changes.
Nix can still need to fetch the app's dependencies into its store.

## Maintenance

Before any dependency update or system upgrade, read the [update inventory](share/packages/README.md) and check all four independently pinned packages.
`nix run .#update` cannot update their custom versions, source hashes, or dependency hashes.
Follow their package-specific update and validation steps before rebuilding.

```bash
# After reviewing every inventory entry:
nix run .#update
# Update and validate custom package definitions as the inventory requires.
nix run .#check
nix run .#rebuild -- macos --dry-run
# On the matching host, when ready to activate:
nix run .#rebuild -- macos
```

Use `nix run .#fix` before `check` when formatting needs a correction.
Review lock-file and source changes before activation.
CI checks formatting and evaluates flakes without a system build or activation.
Package evaluation covers `aarch64-darwin`, `aarch64-linux`, and `x86_64-linux`, plus the two Darwin and two NixOS host configurations.
Evaluation is not a substitute for a successful build or host activation.
Host configurations retain their independent nixpkgs pins.
The optional `witr` CLI and `gh-stack` extension are installed only when the pinned package set provides them.

## Host and package guides

- [Personal macOS setup](macos/README.md)
- [Work macOS operations](macos-work/README.md)
- [NixOS desktop and server operations](nixos/README.md)
- [Raspberry Pi manual setup](raspi/README.md), separate from the four managed host targets
- [Personal application catalogs](share/my/README.md)
- [Custom-package update inventory](share/packages/README.md)
- [Contributor rules](AGENTS.md)
