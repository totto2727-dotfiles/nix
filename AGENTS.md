# Repository maintenance

This standalone repository uses native Nix apps.
Run commands from the repository root.
Use `nix run .#fix` for formatting and `nix run .#check` for formatting checks and all-flake evaluation without system builds.
Do not add JavaScript, pnpm, Vite+, Just, or Task as repository execution dependencies.
Do not install Node.js tools through Nix.
If a workstation needs Vite+, use its official installer as documented in [macOS setup](macos/README.md), not as a repository prerequisite.
CI must not build or activate system configurations.

## Nix maintenance

Before any Nix dependency update or system upgrade, read [the update inventory](share/packages/README.md).
Check every inventory entry, including packages that `nix flake update` cannot update.
Follow the package-specific update and validation steps before running a system rebuild.
Keep the inventory current when you add, remove, or change an independently pinned package in this repository.
Do not treat a successful flake lock update as proof that local package versions are current.

Use `nix run .#update` to print the inventory and update all flake inputs.
It does not update independently pinned package versions or hashes.
Run `nix run .#check` after updates and before activation.
Use `nix run .#rebuild -- <macos|macos-work|nixos|nixos-server> [--dry-run]` for the selected host.
The rebuild app must not update lock files automatically.
Use `sudo` only for the final official host rebuild and switch command, not for dependency updates or checks.
The platform rebuild command can build the configuration before activation.
Use `nix run .#rebuild -- macos --dry-run` for a preview without configuration changes.
