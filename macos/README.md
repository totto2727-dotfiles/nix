# mac

## setup mac

### accessibility > point controll > trackpad

- all true
- all max
- drag lock off

### desktop and dock

- enable auto hidden
- disable used apps
- disable stage manager
  - disable used apps

### do not disturb

20:00~8:00

### trackpad

- speed level 6 (1 start)
- click level low
- enable silent click
- check scroll and zoom/other gesture

### keyboard

- repeat speep max
- globalkey: input source changer

#### keyboard shortcut

- remove ctrl + space shortcut
- enable default function key
- capslock to ctrl

#### text input

- use slash and backslash
- disable input znnkaku number

```bash
# require reboot
defaults write -g ApplePressAndHoldEnabled -bool false
```

## rename computer name

- rename totto2727
- reboot

## setup brew

https://brew.sh/

## setup nix

https://docs.determinate.systems

```bash
nix run nixpkgs#gh -- auth login
nix run nixpkgs#gh -- repo clone totto2727-dotfiles/nix
cd nix
nix develop --command just rebuild-macos
```

## setup chezmoi

```bash
chezmoi init --apply https://github.com/totto2727-dotfiles/chezmoi.git
```

## setup base app

- open 1password
- open browser
  - TODO

## gpg

- <https://christina04.hatenablog.com/entry/create-gpg-master-key-and-subkey>
- <https://text.baldanders.info/remark/2019/10/openpgp-public-keys-in-github/>

