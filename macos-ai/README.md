# Set up the macOS AI guest

This flake configures an Apple silicon macOS guest under the local administrator account `yachi8000`.
It sets the network hostname and Bonjour local hostname to `macos-ai` (`macos-ai.local` for Bonjour).
The `terminal-mac` VM name and the nix-darwin output are independent.
Use `macos-ai` for a new VM or select the existing `yachi8000` pilot. Both use the `macos-ai` flake output.

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

For a new VM, run `"$HOME/.local/bin/terminal-mac" up macos-ai`.
For the already-running pilot, open its native window with `"$HOME/.local/bin/terminal-mac" show yachi8000`.

1. In the VM window, complete macOS Setup Assistant. Create a local administrator with the short account name `yachi8000` and sign in.
2. Inside the guest, open `/Volumes/My Shared Files/tools/TerminalMacGuest.app` in Finder. It installs and opens a copy in `~/Applications`.
3. Use the helper's buttons to grant **Screen Recording** and **Accessibility** in the guest's System Settings. Reopen the helper if macOS asks, and approve its login item if prompted. Keep the guest signed in and the helper running when you use its channel.

For initial setup, use the native VM window directly or target that window on the unlocked host with [Orca Computer Use](https://orca.dev/docs/cli/computer-use) or [Codex desktop Computer Use](https://learn.chatgpt.com/docs/computer-use).
Grant host Screen Recording and Accessibility permissions to the desktop control tool you choose. The terminal-mac helper permissions are separate and belong to the guest.
Use `orca computer list-apps --json` and `orca computer list-windows --app <app-id> --json` to identify the window, or select the terminal-mac app and VM window in Codex Computer Use.
In the pilot host-lock check, Orca returned `screen_locked` and Codex returned `cgWindowNotFound` on the VM window. Unlock the host and make the VM window available before retrying.

After the helper is ready, you can use its guest channel from the host with `"$HOME/.local/bin/terminal-mac" action macos-ai status` or `"$HOME/.local/bin/terminal-mac" view macos-ai`.
Use `yachi8000` in those commands for the pilot. See the [terminal-mac agent guide](https://github.com/govijr/terminal-mac/blob/v0.2.0-6/docs/AGENT.md) for the optional MCP channel.
Enter passwords and approve permissions yourself in the guest UI.

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

In that shell, sign in to GitHub with an account that can read both private repositories and approve organization SSO if prompted.
Complete the browser flow yourself. Use the guest's credential store. [GitHub CLI sign-in](https://cli.github.com/manual/gh_auth_login)

```bash
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git --hostname github.com
gh auth status --hostname github.com
git clone https://github.com/totto2727-org/workspace.git "$HOME/workspace"
git clone https://github.com/totto2727-dotfiles/nix.git "$HOME/workspace/nix"
```

The workspace root has no submodule for `nix/`. The second clone is a separate Git checkout at the path reserved by the workspace's `.gitignore`.

## Build and activate the pinned configuration

Run `switch` only in the guest. It changes the active macOS configuration and prompts for the guest administrator password.
Determinate Nix continues to manage Nix through `nix.enable = false`. [Determinate Nix with nix-darwin](https://docs.determinate.systems/guides/nix-darwin/)

```bash
cd "$HOME/workspace/nix"
guest_system=$(nix build --no-link --no-update-lock-file --print-out-paths \
  './macos-ai#darwinConfigurations.macos-ai.system') &&
  sudo "$guest_system/sw/bin/darwin-rebuild" switch --no-update-lock-file \
    --flake "$HOME/workspace/nix/macos-ai#macos-ai"
```

Exit the temporary bootstrap shell and open a new guest Terminal window so the activated profile is on `PATH`.

```bash
gh auth setup-git --hostname github.com
codex login
```

Complete the Codex sign-in in the guest with the account authorized for this VM. [Codex authentication](https://learn.chatgpt.com/docs/auth)

## Pair the guest with Orca

1. Install Orca on the guest and the client Mac from the [Orca install guide](https://orca.dev/docs/install). Open Orca in the guest, add `$HOME/workspace` as a project, and sign in to any provider Orca prompts for using the guest's own login state.
2. Install Tailscale on both machines from the [macOS install guide](https://tailscale.com/docs/install/mac). Use the [Standalone variant](https://tailscale.com/docs/concepts/macos-variants) on a fresh guest. Approve the system extension and VPN configuration if prompted, sign in to the same private tailnet on both machines, and approve the new device if your tailnet requires it.
3. In guest Orca, open **Settings → Remote Orca Servers → New Link**, select the guest's Tailscale address, and generate an access link. Enter the link privately in **Settings → Remote Orca Servers → Add Server** on the client. Keep the guest awake, signed in, and running Orca. Keep the server on the private tailnet. [Remote Orca Servers](https://orca.dev/docs/remote-servers)

Treat the pairing link like a password. Keep it out of the shared folder, repositories, logs, and chat. Revoke a client's grant from the guest's **Shared Server Access** settings when access is no longer needed.

## Transfer Bot files and provision secrets if needed

If the guest needs existing Bot instructions, memory, or skills, review and select the non-secret files individually. Transfer those files through an approved private connection, such as SFTP over your tailnet. Put them in the guest's Bot or agent configuration and adjust any host-specific paths.
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

- Confirm `id -un` returns `yachi8000` and `uname -m` returns `arm64`.
- Confirm `scutil --get HostName` and `scutil --get LocalHostName` both return `macos-ai`. Check that `test -x /run/current-system/sw/bin/darwin-rebuild` succeeds.
- Run `codex --version`, `gh --version`, `git --version`, `jq --version`, `python3 --version`, `rg --version`, and `pass-cli version`. Pass CLI should report `0.20.0`.
- Run `git -C "$HOME/workspace" remote get-url origin` and `git -C "$HOME/workspace/nix" remote get-url origin`. Confirm the URLs match the two clone commands. Run `gh auth status --hostname github.com` and `codex login status`.
- In client Orca, check that the guest server shows **Connected** and open a remote terminal. Confirm that `id -un` returns `yachi8000` and the workspace is available.

The Apple silicon host build with `nix build --no-link` and version checks from the resulting profile passed without activating it.
For the pilot, guest GUI setup, guest activation, service sign-in, and Orca pairing are pending initial GUI access.
