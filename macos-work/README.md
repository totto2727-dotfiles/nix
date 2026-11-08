# Work macOS operations

This guide is for maintainers of the work macOS host.
Run commands from the repository root.
For updates, first read the [update inventory](../share/packages/README.md) and check every entry.

```bash
nix run .#update
nix run .#check
nix run .#rebuild -- macos-work --dry-run
nix run .#rebuild -- macos-work
```

The rebuild does not update lock files automatically.
See the [root guide](../README.md) for prerequisites and command behavior.

## Podman machine setup

These manual operations require an existing Podman machine.
They replace registry configuration inside the VM and restart it.
Review the remote configuration before applying it, and stop active container workloads first.

```bash
podman machine ssh --username root rm -f /etc/containers/registries.conf.d/000-shortnames.conf
podman machine ssh --username root 'curl -fL https://raw.githubusercontent.com/totto2727-dotfiles/chezmoi/refs/heads/main/dot_config/containers/registries.conf > /etc/containers/registries.conf'
podman machine stop
podman machine start
podman run --rm -it --device /dev/dri --name gpu-info quay.io/slopezpa/fedora-vgpu vulkaninfo
```

To start the optional PlantUML server:

```bash
podman run -d -p 127.0.0.1:8080:8080 --read-only plantuml/plantuml-server:jetty
```

## VS Code extensions

These commands need `code` and `jq` on `PATH`.
To install the recorded extensions:

```bash
jq -r '.[]' macos-work/vscode/extensions.json | xargs -I {} code --install-extension {}
```

To replace the recorded list with the installed extensions:

```bash
code --list-extensions | jq -R -s 'split("\n") | map(select(length > 0))' > macos-work/vscode/extensions.json
```

Review the JSON diff before committing it.
