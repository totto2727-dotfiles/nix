# Set up the yachi8000 macOS guest

Use `yachi8000` as the `terminal-mac` VM name, the local administrator account, and the nix-darwin output for this Apple silicon guest.
The flake sets the guest's Sharing name and network hostname to `yachi8000` and its Bonjour name to `yachi8000.local`.

## Boot the VM on the host

Use an Apple silicon Mac with macOS 14 or later, internet access to download the Apple restore image or a compatible local `.ipsw`, and space for the image and sparse guest disk (64 GiB logical by default).
The inline viewer requires Ghostty, Kitty, or iTerm2. The native VM window works from other terminals.
Use the [terminal-mac v0.2.0-6 release](https://github.com/govijr/terminal-mac/releases/tag/v0.2.0-6) and its [versioned setup guide](https://github.com/govijr/terminal-mac/tree/v0.2.0-6).

On a host without terminal-mac, download and check the release archive before running its installer.

```bash
release_dir=$(mktemp -d)
cd "$release_dir"
release_url=https://github.com/govijr/terminal-mac/releases/download/v0.2.0-6
archive=terminal-mac-0.2.0-6-macos-arm64.zip
curl -fLO "$release_url/$archive" &&
  curl -fLO "$release_url/$archive.sha256" &&
  shasum -a 256 -c "$archive.sha256" &&
  unzip -q "$archive" &&
  bash terminal-mac-0.2.0-6-macos-arm64/install.sh
```

For a new VM, run `"$HOME/.local/bin/terminal-mac" up yachi8000`.
For the already-running pilot, open its native window with `"$HOME/.local/bin/terminal-mac" show yachi8000`.

1. In the VM window, complete macOS Setup Assistant. Create a local administrator with the short account name `yachi8000` and sign in.
2. Inside the guest, open `/Volumes/My Shared Files/tools/TerminalMacGuest.app` in Finder. It installs and opens a copy in `~/Applications`.
3. Use the helper's buttons to grant **Screen Recording** and **Accessibility** in the guest's System Settings. Reopen the helper if macOS asks, and approve its login item if prompted. Keep the guest signed in and the helper running when you use its channel.

For initial setup, use the native VM window directly or target that window on the unlocked host with [Orca Computer Use](https://orca.dev/docs/cli/computer-use) or [Codex desktop Computer Use](https://learn.chatgpt.com/docs/computer-use).
Grant host Screen Recording and Accessibility permissions to the desktop control tool you choose. The terminal-mac helper permissions are separate and belong to the guest.
Use `orca computer list-apps --json` and `orca computer list-windows --app <app-id> --json` to identify the window, or select the terminal-mac app and VM window in Codex Computer Use.
In the pilot host-lock check, Orca returned `screen_locked` and Codex returned `cgWindowNotFound` on the VM window. Unlock the host and make the VM window available before retrying.

Enter passwords and approve permissions yourself in the guest UI.

## Keep the guest desktop available during setup

In the guest only, open **System Settings → Lock Screen** and set the following controls to **Never** where offered. Keep the host's lock settings unchanged. [Apple Lock Screen settings](https://support.apple.com/en-mt/guide/mac-help/mh11784/27/mac/27)

- **Start Screen Saver when inactive**.
- **Turn display off when inactive**. Set each power-source control the guest offers.
- **Require password after screen saver begins or display is turned off**.

If macOS 27 shows the screen saver timer under **System Settings → Wallpaper → Screen Saver**, set **Start Screen Saver** to **Never** there. [Apple Screen Saver settings](https://support.apple.com/en-euro/guide/mac-help/mchlp1227/27/mac/27)
Reopen the settings to confirm the selected values. These settings apply to inactivity. Choosing **Lock Screen** is a separate manual action.

On the host, check the VM state, the helper permissions, and whether the helper can capture the guest desktop.

```bash
"$HOME/.local/bin/terminal-mac" status yachi8000
"$HOME/.local/bin/terminal-mac" action yachi8000 status
"$HOME/.local/bin/terminal-mac" action yachi8000 screenshot
```

After the screenshot shows the guest desktop, close the native VM window or run `"$HOME/.local/bin/terminal-mac" hide yachi8000`.
Use the action channel with the window hidden, or open the inline viewer with `"$HOME/.local/bin/terminal-mac" view yachi8000`. [terminal-mac agent guide](https://github.com/govijr/terminal-mac/blob/v0.2.0-6/docs/AGENT.md)

If `action status` reports permissions but the screenshot fails with `No guest display is available`, open the native window briefly to wake the guest. On the pilot, `"$HOME/.local/bin/terminal-mac" show yachi8000` followed by pressing **Escape** on the physical keyboard with the VM window focused restored screenshots. Retry `action yachi8000 screenshot` and hide the window again once it works. [terminal-mac issue #6](https://github.com/govijr/terminal-mac/issues/6)

## Install Determinate Nix in the guest

Run the remaining setup in the guest as `yachi8000`.
Download the signed [Determinate.pkg](https://install.determinate.systems/determinate-pkg/stable/Universal) from [Determinate Systems](https://docs.determinate.systems/).
Check that the package has a trusted Developer ID Installer signature from Determinate Systems with team ID `X3JQ4VPJZ6` before opening it. [Determinate package signing](https://docs.determinate.systems/guides/mdm/)

```bash
curl -fL https://install.determinate.systems/determinate-pkg/stable/Universal \
  -o "$HOME/Downloads/Determinate.pkg"
pkgutil --check-signature "$HOME/Downloads/Determinate.pkg"
```

Open the verified package, follow Installer, and enter the guest administrator password when prompted.
Open a new Terminal window after installation and start a temporary shell with Git and GitHub CLI from the public nixpkgs registry.

```bash
nix --version
nix shell nixpkgs#gitMinimal nixpkgs#gh --command /bin/zsh -f
git --version
gh --version
```

## Clone the two repositories

Start GitHub sign-in in the guest bootstrap shell and leave the command running while the owner approves it in their own browser.

```bash
BROWSER=/usr/bin/true GH_PROMPT_DISABLED=1 gh auth login \
  --hostname github.com --git-protocol https --web --skip-ssh-key
```

In the owner's browser, open [GitHub device login](https://github.com/login/device) and enter the one-time code printed by `gh`. Use an account that can read both private repositories. Approve organization SSO if prompted. The guest CLI stores its own sign-in. [GitHub CLI sign-in](https://cli.github.com/manual/gh_auth_login)

After `gh` reports success, configure Git and clone the repositories in the guest.

```bash
gh auth setup-git --hostname github.com
gh auth status --hostname github.com
git clone https://github.com/totto2727-org/workspace.git "$HOME/workspace"
git clone https://github.com/totto2727-dotfiles/nix.git "$HOME/workspace/nix"
```

The workspace root has no submodule for `nix/`. The second clone is a separate Git checkout at the path reserved by the workspace's `.gitignore`.

Use `main` after [PR #7](https://github.com/totto2727-dotfiles/nix/pull/7) merges.
To set up a fresh guest before the merge, switch the Nix checkout to the PR branch in the same bootstrap shell.

```bash
git -C "$HOME/workspace/nix" switch --track origin/totto2727/macos-ai
```

## Build and activate the pinned configuration

Run `switch` only in the guest. It changes the active macOS configuration and prompts for the guest administrator password.
Determinate Nix continues to manage Nix through `nix.enable = false`. [Determinate Nix with nix-darwin](https://docs.determinate.systems/guides/nix-darwin/)
The same switch activates Home Manager for `yachi8000` and installs the seven tools under `/etc/profiles/per-user/yachi8000/bin`. [Home Manager's nix-darwin module](https://nix-community.github.io/home-manager/installation/nix-darwin.html)

```bash
cd "$HOME/workspace/nix"
guest_system=$(nix build --no-link --no-update-lock-file --print-out-paths \
  './yachi8000#darwinConfigurations.yachi8000.system') &&
  sudo "$guest_system/sw/bin/darwin-rebuild" switch --no-update-lock-file \
    --flake "$HOME/workspace/nix/yachi8000#yachi8000"
```

Exit the temporary bootstrap shell and open a new guest Terminal window so Zsh loads the updated `PATH`.
If Orca was already open in the guest, quit and reopen it after the switch. Keep the default login shell arguments for Orca terminals. [Orca terminal startup](https://orca.dev/docs/terminal)

```bash
gh auth setup-git --hostname github.com
codex login --device-auth
```

In the owner's browser, open [Codex device login](https://auth.openai.com/codex/device), sign in to the authorized account, and enter the code printed in the guest. If prompted, enable device code sign-in in ChatGPT's security settings or ask the workspace admin to enable it. When the guest command finishes, run `codex login status` in the guest. [Codex authentication](https://learn.chatgpt.com/docs/auth)

## Connect the guest to the private tailnet

Install the [Tailscale Standalone app](https://tailscale.com/docs/concepts/macos-variants) in the guest and open it. Enable its network extension and approve the VPN configuration in the guest. [Tailscale macOS install guide](https://tailscale.com/docs/install/mac)

Run the app's CLI in the guest. Leave it running while the owner opens the separate sign-in URL it prints in their browser and approves the guest for the same private tailnet as the client Mac. Approve the new device if the tailnet requires it. [Tailscale `up`](https://tailscale.com/docs/reference/tailscale-cli/up)

```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale up --hostname=yachi8000
/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4
```

Use the IPv4 address printed by the second command for Orca pairing. After guest permissions and installations are in place, GitHub, Codex, and Tailscale sign-in require only the owner's browser approvals. Keep one-time codes and the Tailscale sign-in URL out of logs and chat.

## Pair the guest with Orca

Install Orca on the guest and the client Mac. Open Orca in the guest and register the CLI under **Settings → General → Orca CLI**. Add the workspace from the guest terminal. [Orca install guide](https://orca.dev/docs/install)

```bash
orca repo add --environment local --path "$HOME/workspace" --json
```

In guest Orca, open **Settings → Remote Orca Servers → New Link**. Select the guest's Tailscale IP as the connection address and generate an access link. In client Orca, open **Settings → Remote Orca Servers → Add Server** and enter the link privately. Keep Orca running in the signed-in guest on the private tailnet. [Remote Orca Servers](https://orca.dev/docs/remote-servers)

To add the environment from the client CLI instead, enter the link at a hidden prompt in a private local terminal. The prompt keeps the link out of shell history. The CLI still receives it as a process argument. [Orca CLI reference](https://orca.dev/docs/cli/reference)

```bash
(
  set +x
  printf '%s\n' 'Paste the private Orca access link, then press Enter.'
  IFS= read -r -s access_link &&
    orca environment add --name yachi8000 --pairing-code "$access_link"
)
```

Treat the pairing link like a password. Keep it out of the shared folder, repositories, logs, and chat. Revoke a client's grant from the guest's **Shared Server Access** settings when access is no longer needed.

## Transfer Bot files and provision secrets if needed

If the guest needs existing Bot instructions, memory, or skills, review and select the non-secret files individually. Transfer those files through an approved private connection, such as SFTP over your tailnet. Put them in the guest's Bot or agent configuration and adjust any host-specific paths.
Keep the Bot's state in writable files owned by the guest user. Keep those files and secrets outside Git and the Nix store.
Sign in and authorize devices separately in the guest. Keep host tokens, authentication files, identity or session data, the host Keychain, and host vaults on the host. Use the terminal-mac shared folder for its helper and transport. Keep credentials and vault files out of the shared folder, repositories, logs, and chat.

The flake installs the [community reyamira Pass CLI v0.20.0](https://github.com/reyamira/pass-cli/releases/tag/v0.20.0).
To create a guest-only vault, run the following commands in an unrecorded guest Terminal. Choose a new vault and enter its master password and any approved guest-specific secret yourself. Store the recovery phrase privately offline. [Pass CLI quick start](https://reyamira.github.io/pass-cli/01-getting-started/quick-start/)

```bash
pass-cli init --no-sync
pass-cli add github-agent
```

If you use a vault already set up for this guest, unlock it yourself. If you choose Keychain integration, authorize Pass CLI only for its entry in the guest login Keychain. Keep the master password and recovery phrase out of automation, shell arguments, files used for transfer, and transcripts. [Pass CLI Keychain setup](https://reyamira.github.io/pass-cli/02-guides/keychain-setup/)

For a command that needs an approved GitHub token stored as `github-agent`, inject it into that child process. Run a command that does not print credentials, and leave debugging and shell tracing off. Child processes can inherit the variable. [Pass CLI agent integration](https://reyamira.github.io/pass-cli/02-guides/ai-agents/)

```bash
pass-cli exec --set GH_TOKEN=github-agent -- \
  gh repo view totto2727-org/workspace --json nameWithOwner --jq .nameWithOwner
```

## Verify the guest

- Verify the guest's inactivity settings and repeat `"$HOME/.local/bin/terminal-mac" action yachi8000 screenshot` from the host after leaving the guest idle with the native window hidden.
- Confirm `id -un` returns `yachi8000` and `uname -m` returns `arm64`.
- Confirm `scutil --get ComputerName`, `scutil --get HostName`, and `scutil --get LocalHostName` all return `yachi8000`. Check that `test -x /run/current-system/sw/bin/darwin-rebuild` succeeds.
- In a fresh guest Terminal, run `command -v codex gh git jq python3 rg pass-cli`. Each path should start with `/etc/profiles/per-user/yachi8000/bin/`.
- Run `codex --version`, `gh --version`, `git --version`, `jq --version`, `python3 --version`, `rg --version`, and `pass-cli version`. Pass CLI should report `0.20.0`.
- Run `git -C "$HOME/workspace" remote get-url origin` and `git -C "$HOME/workspace/nix" remote get-url origin`. Confirm the URLs match the two clone commands. Run `gh auth status --hostname github.com` and `codex login status`.
- In the guest, run `/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4` and confirm that Orca uses that address for pairing.
- In client Orca, check that the guest server shows **Connected** and open a new remote terminal. Confirm the account, workspace, and command paths match the guest Terminal. Confirm that guest Orca detects Codex in **Settings → Agents**. [Orca agent troubleshooting](https://orca.dev/docs/troubleshooting)

The Apple silicon host build with `nix build --no-link` verified the generated Home Manager activation script, per-user profile, and all seven tool versions without activating the configuration.
The pilot verified guest-side sign-in for GitHub CLI, Codex, and Tailscale with the browser flows above. Use the client Orca checks to verify the remote connection and terminal separately.
