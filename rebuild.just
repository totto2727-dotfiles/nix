default:
    @just --list --list-submodules

[working-directory('macos')]
macos:
    sudo nix flake update --option access-tokens "github.com=$(gh auth token)"
    sudo nix run nix-darwin -- switch --flake .

[working-directory('macos-work')]
macos-work:
    sudo nix flake update --option access-tokens "github.com=$(gh auth token)"
    sudo nix run nix-darwin -- switch --flake .

[working-directory('nixos')]
nixos:
    sudo nix flake update --option access-tokens "github.com=$(gh auth token)"
    sudo nixos-rebuild switch --flake .#nixos
    mkdir -p $HOME/.local/share/fonts && cp -f -L /run/current-system/sw/share/X11/fonts/* $HOME/.local/share/fonts/
    flatpak --user override --filesystem=$HOME/.local/share/fonts:ro
    flatpak --user override --filesystem=$HOME/.icons:ro
    flatpak update -y

[working-directory('nixos-server')]
nixos-server:
    sudo nix flake update --option access-tokens "github.com=$(gh auth token)"
    sudo nixos-rebuild switch --flake .#nixos
