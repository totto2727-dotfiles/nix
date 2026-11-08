# NixOS operations

This guide is for maintainers of the NixOS desktop and server.
Run repository commands from the repository root.
Before an update or upgrade, read the [update inventory](../share/packages/README.md) and check every entry.

## Desktop setup

```bash
nix run .#update
nix run .#check
nix run .#rebuild -- nixos --dry-run
nix run .#rebuild -- nixos
LANG=C xdg-user-dirs-update --force
```

The last command resets user-directory names to the English defaults.
Review the target host's `hardware-configuration.nix` before its first activation.
For an initial activation that needs an explicit binary cache, after the inventory, update, and check steps:

```bash
sudo nixos-rebuild switch --flake ./nixos#nixos \
  --option extra-substituters https://install.determinate.systems \
  --option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
```

## Server setup

Use the server target on the server host, not the desktop target.
After the inventory review:

```bash
nix run .#update
nix run .#check
nix run .#rebuild -- nixos-server --dry-run
nix run .#rebuild -- nixos-server
chezmoi init https://github.com/totto2727-dotfiles/chezmoi
chezmoi apply
```

If initial activation requires explicit feature and cache options, use this activation command after update and check:

```bash
sudo nixos-rebuild switch --flake ./nixos-server#nixos \
  --experimental-features 'nix-command flakes' \
  --option extra-substituters https://install.determinate.systems \
  --option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
```

To advertise the configured server subnet through Tailscale:

```bash
sudo tailscale up --ssh --advertise-routes 172.32.0.0/12
```

Verify the route and tailnet policy before enabling subnet routing.
The rebuild app never updates lock files automatically.

## Desktop preferences

- appearance
  - interface: narrow
  - system font: IBM Plex Sans JP
  - mono font: `PlemolJP`
  - thema config > apply to gnome applications: true
- panel
  - opacity: 50%
- dock
  - auto hidden: true
  - opacity: 50%

## display

- scaling: 175%

## sound

- setup device profiles

## application

- check default application
- x11 compatibility > scaling: game mode

## terminal

- ~/.config/cosmic/com.system76.CosmicTerm/v1/profiles
  ```json
  {
      0: (
          name: "Default",
          command: "zsh",
          syntax_theme_dark: "COSMIC Dark",
          syntax_theme_light: "COSMIC Light",
          tab_title: "",
          working_directory: "/home/totto2727",
          drain_on_exit: false,
      ),
  }
  ```

## nordvpn

blocked: https://github.com/NixOS/nixpkgs/pull/406725

```bash
sudo nordvpn login
sudo systemctl restart nordvpn
sudo nordvpn connect
```

## flatpak

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub app.zen_browser.zen
flatpak install flathub com.github.tchx84.Flatseal
```

## Flatpak resources after a desktop rebuild

If Flatpak applications need the system fonts and icons, run:

```bash
mkdir -p "$HOME/.local/share/fonts"
cp -f -L /run/current-system/sw/share/X11/fonts/* "$HOME/.local/share/fonts/"
flatpak --user override --filesystem="$HOME/.local/share/fonts:ro"
flatpak --user override --filesystem="$HOME/.icons:ro"
flatpak update
```

The copy replaces files with matching names in the destination.
These manual operations are separate from system activation.

## waydroid

1. `sudo waydroid init`
1. `sudo systemctl start waydroid-container`
1. `waydroid-helper`
   1. extension > LiteGpapps > Show > install
   1. extension > ndk_translation > ndk_translation-chromeos_zork
1. change language
1. `sudo waydroid shell`
1. `ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"`
1. open https://www.google.com/android/uncertified/
1. `sudo systemctl restart waydroid-container`
1. open waydroid

## tailscale

1. `sudo tailscale up --ssh`
