# Personal macOS setup

This guide is for maintainers setting up the personal macOS host.
Run repository commands from the repository root.

## setup mac

### accessibility > point controll > trackpad

- all true
- all max
- drag lock off

### desktop and dock

- enable auto hidden
- disable used apps
- enable stage manager
  - disable used apps

### do not disturb

8:00~20:00

### trackpad

- speed level 6 (1 start)
- click level low
- enable silent click
- check scroll and zoom/other gesture

### keyboard

- repeat speep max

#### keyboard shortcut

- remove ctrl + space shortcut
- enable default function key
- use slash and backslash
- disable input znnkaku number

```bash
# require reboot
defaults write -g ApplePressAndHoldEnabled -bool false
```

## rename computer name

- rename totto2727
- reboot

## safari

- add 1password extention

## setup brew

https://brew.sh/

## setup nix

https://docs.determinate.systems

```bash
git clone https://github.com/totto2727-dotfiles/nix.git
cd nix
# Read share/packages/README.md and check every inventory entry first.
nix run .#update
nix run .#check
nix run .#rebuild -- macos --dry-run
nix run .#rebuild -- macos
```

## Optional workstation CLI installers

These tools are workstation applications, not repository dependencies.
Review the official installer before executing it.
Install Vite+ through its official installer, not through Nix.
Do not install Node.js tools through Nix.

```bash
# Jcode
curl -fsSL https://jcode.sh/install | bash
# MoonBit
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
# Vite+
curl -fsSL https://vite.plus | bash
```

## setup chezmoi

```bash
chezmoi init --apply https://github.com/totto2727-dotfiles/chezmoi.git
```

## setup base app

- open 1password
- open browser
  - TODO
- open and login logi-options+
  - restore backup

## gpg

- <https://christina04.hatenablog.com/entry/create-gpg-master-key-and-subkey>
- <https://text.baldanders.info/remark/2019/10/openpgp-public-keys-in-github/>

## setup karabiner driver and kanata

https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/blob/main/dist/Karabiner-DriverKit-VirtualHIDDevice-6.9.0.pkg or karabiner app

```bash
/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate
```

```bash
karabiner
kanata
```
