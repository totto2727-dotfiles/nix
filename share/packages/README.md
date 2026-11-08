# Nix update inventory

This guide is for maintainers who update Nix dependencies or rebuild systems.
Read it before every Nix dependency update or system upgrade, as required by [root AGENTS.md](../../AGENTS.md).

## Independently pinned packages

| Package             | Definition     | Dependency lock            | Official version source                                   |
| ------------------- | -------------- | -------------------------- | --------------------------------------------------------- |
| `monid`             | `monid.nix`    | Generated `monid-bun.nix`  | [Releases](https://github.com/monid-ai/cli/releases)      |
| `oo-cli` (`oo`)     | `oo-cli.nix`   | Generated `oo-cli-bun.nix` | [Releases](https://github.com/oomol-lab/oo-cli/releases)  |
| `pass-cli`          | `pass-cli.nix` | `vendorHash`               | [Releases](https://github.com/reyamira/pass-cli/releases) |
| `by-binds-yourself` | `../zsh.nix`   | Source hash                | [Tags](https://github.com/atusy/by-binds-yourself/tags)   |

The definitions contain the installed versions.
Do not keep a second version list in this document.

## Required update sequence

Run commands from the repository root.

1. Check every entry against its official releases or tags, even if its version does not need a change.
2. Select stable releases that satisfy the repository's minimum release age of 24 hours.
3. Review upstream changes for build, runtime, and wrapper compatibility.
4. Update each changed definition and regenerate its dependency lock with the steps below.
5. Run the package checks and shared checks before a system rebuild.
6. Run `nix run .#update` to refresh all flake inputs, then run `nix run .#check` and the target system's rebuild procedure.

`nix run .#update` prints this inventory before it updates flake inputs.
It does not check upstream custom-package releases or change their versions.

`nix flake update` updates flake inputs, such as `nixpkgs` and `bun2nix`.
It does not update versions, source hashes, or dependency hashes in these local definitions.
There is no single update command for all inventory entries.
Do not use a text replacement alone or update transitive dependencies independently of the upstream lock file.
Keep generated `*-bun.nix` files synchronized with the selected upstream `bun.lock`.

The root, `macos`, `macos-work`, `nixos`, and `nixos-server` flakes use local path inputs for `share/packages`.
They read these package definitions directly.
Do not update unrelated flake inputs only to propagate a local package version change.

## Source hashes

For a changed GitHub source, set its `hash` to `lib.fakeHash`, then build its source:

```bash
nix build ./share/packages#monid.src --no-link
```

Use the relevant package name instead of `monid`.
This build is expected to fail with a hash mismatch.
Copy the reported `got` hash into the definition, then repeat the build successfully.
Do not commit `lib.fakeHash`.

## monid

### Update

Update `version` and the source hash in `monid.nix`, then regenerate dependencies:

```bash
source=$(nix build ./share/packages#monid.src --no-link --print-out-paths)
nix run ./share/packages#bun2nix -- \
  --lock-file "$source/bun.lock" \
  --output-file share/packages/monid-bun.nix
```

### Validate

```bash
nix build ./share/packages#monid --no-link
nix run ./share/packages#monid -- --version
nix run ./share/packages#monid -- --help
```

## oo-cli

### Update

Update `version` and the source hash in `oo-cli.nix`, then regenerate dependencies:

```bash
source=$(nix build ./share/packages#oo-cli.src --no-link --print-out-paths)
nix run ./share/packages#bun2nix -- \
  --lock-file "$source/bun.lock" \
  --output-file share/packages/oo-cli-bun.nix
```

### Validate

```bash
nix build ./share/packages#oo-cli --no-link
nix run ./share/packages#oo-cli -- version --json
nix run ./share/packages#oo-cli -- --help
nix run ./share/packages#oo-cli -- skills info --source bundled --json
```

## pass-cli

### Update

Update `version`, `rev`, the build date in `ldflags`, and hashes in `pass-cli.nix`.
Use the selected release's source commit and commit timestamp for the embedded metadata.
Set changed hashes to `lib.fakeHash`, build, and use the reported hashes.
Update the source hash first, then update `vendorHash` if the Go dependency set changed.

### Validate

```bash
nix build ./share/packages#pass-cli --no-link
nix run ./share/packages#pass-cli -- version
```

## by-binds-yourself

Update `rev` in `share/zsh.nix` to the selected upstream tag.
Set `sha256` to `pkgs.lib.fakeHash`, then run:

```bash
nix build --impure --no-link --expr '
  let
    packages = builtins.getFlake (toString ./share/packages);
    pkgs = packages.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  in (builtins.head (import ./share/zsh.nix { inherit pkgs; }).plugins).src
'
```

Replace the placeholder with the reported `got` hash, then repeat the command successfully.
Check the plugin in an interactive Zsh session after the target system rebuild.

## Shared checks

```bash
nix run .#fix
nix run .#check
nix flake check ./share/packages --all-systems --no-build
```

Builds run on the current system; `--all-systems --no-build` only evaluates other systems.
