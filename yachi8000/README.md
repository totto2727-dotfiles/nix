# Set up the yachi8000 macOS guest

Use `yachi8000` as the `terminal-mac` VM name, the local administrator account, and the nix-darwin output for this Apple silicon guest.
The flake sets the guest's Sharing name and network hostname to `yachi8000` and its Bonjour name to `yachi8000.local`.

## When the owner needs to act

The operator runs the setup and shell commands.
Check the guest's existing sign-ins and permissions before requesting approval.
Generate time-limited codes when the owner is ready, then send the usable browser URL and any code as copyable text in a private conversation.
Continue independent work while waiting.
Reissue only the expired or failed provider request.
For a progress estimate, give the owner a checklist of pending approvals.

| Stage | Operator prepares | When to involve the owner | Owner action | Continue when |
| --- | --- | --- | --- | --- |
| 1. [Boot macOS](#boot-the-vm-on-the-host) | Start the VM and download the Nix installer. Show the actual license screen if consent is missing. | Setup Assistant asks for consent and the owner has yet to give it. | Review the license and accept it on that screen if they agree. | Setup Assistant advances. |
| 2. Create the guest administrator | Fill in the guest account details and open the password fields. | The account needs a guest-only password. | Type it directly in the guest, or explicitly authorize the operator to generate one and store it in the host login Keychain, as in the pilot. | The guest administrator can sign in. |
| 3. Enable guest controls | Open TerminalMacGuest and check its guest permissions. | macOS asks for Accessibility or Screen Recording consent in the guest. | Review and allow each requested guest permission. | Guest helper status and screenshot work. Hide the native VM window. |
| 4. Prepare the guest | [Configure display and sleep](#keep-the-guest-desktop-available-during-setup) and [install Determinate Nix](#install-determinate-nix-in-the-guest). | A guest administrator prompt requires the owner's input. | Type the guest password directly in the prompt. | The settings readbacks and `nix --version` pass. |
| 5. [Authorize GitHub and clone](#clone-the-two-repositories) | Check guest GitHub sign-in and access to both bootstrap repositories. Start device login if needed. | The guest command prints a usable URL and code. | Open the private handoff in a browser, enter the code, and approve GitHub access and any required organization SSO. | Guest GitHub access works for both bootstrap repositories. Clone them. |
| 6. [Activate the profile and authorize Codex](#build-and-activate-the-pinned-configuration) | Build and switch in the guest. Check `codex login status` and start device login if needed. | The guest command prints a usable URL and code. | Open the device page, enter the code, and approve the intended Codex account. | The profile is active and guest Codex sign-in is confirmed. |
| 7. [Join the private tailnet](#connect-the-guest-to-the-private-tailnet) | Install and prepare guest Tailscale, check its connection, and start sign-in if needed. | The guest prints a usable sign-in URL or the tailnet requires device approval. | If sign-in is pending, open the private URL and choose the intended tailnet. Approve the guest device if required. | The client can reach the guest on Tailscale. |
| 8. [Pair and verify Orca](#pair-the-guest-with-orca) | Register the remote environment with the Orca CLI. List the guest workspace and [check a remote terminal](#verify-the-guest). | No owner handoff for these checks. | No action. | The workspace appears and the remote terminal confirms the guest host and project directory. |

Use the terminal-mac guest controls or a working remote session.
Ask the owner to unlock the host only if the available route fails and you need an interactive host session.
If the helper has permissions but reports `No guest display is available`, use the [physical Escape recovery](#keep-the-guest-desktop-available-during-setup) and hide the window again after the screenshot works.

### Optional handoffs

| Branch | Operator prepares | When to involve the owner | Owner action | Continue when |
| --- | --- | --- | --- | --- |
| [Orca Mobile](https://orca.dev/docs/mobile#pairing) | Once Tailscale is reachable, generate the native Orca Mobile QR or a copyable pairing link. Both grant access, so share them privately. Give the owner the guest host, workspace, and terminal tab to open. | The owner needs mobile access. | Pair in Orca Mobile and open the named guest screen or terminal. | The owner can see the intended screen before entering anything. The pilot verified QR generation and sharing. |
| [Guest Orca configuration](#configure-orca-in-the-guest) | Follow the guest configuration repository's instructions for the Bot, tools, abilities, and schedules. | The owner expects Slack delivery or another connector requires the owner's approval. | Follow the [owner connector steps](https://github.com/totto2727-dotfiles/orca-macos-guest#オーナーが登録するコネクター) to approve the required connections. | The guest configuration repository's checks pass. |
| [Guest Pass CLI vault](#set-up-a-temporary-guest-vault) | Open an unrecorded guest Terminal. Give the owner the guest host, workspace, terminal tab title, and master password prompt. | The owner is ready to initialize the vault or authorize its guest Keychain entry. | Enter the guest vault password directly in that terminal. During initialization, store the recovery phrase offline. | The vault is initialized. If Keychain is enabled, verify `Password Stored: Yes` and confirm that the vault opens without prompting or printing entries. |

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

In the macOS 27 guest, open **System Settings → Lock Screen** and set the following controls to **Never** where offered. Keep the host's lock settings unchanged. [Apple Lock Screen settings](https://support.apple.com/en-mt/guide/mac-help/mh11784/27/mac/27)

- **Turn display off when inactive**. Set each power-source control the guest offers.
- **Require password after screen saver begins or display is turned off**.

In **System Settings → Wallpaper → Screen Saver**, set **Start Screen Saver** to **Never**. Reopen both panels to confirm the selected values. These settings apply to inactivity. Choosing **Lock Screen** is a separate manual action. [Apple Screen Saver settings](https://support.apple.com/en-euro/guide/mac-help/mchlp1227/27/mac/27)

Authenticate the password prompt in the guest. If the password setting needs a CLI fallback, run this command as the signed-in guest user. The final `-` prompts for the guest password interactively.

```bash
sysadminctl -screenLock off -password -
```

In the guest only, set its AC power profile to keep the VM awake when idle, then read back the inactivity settings.

```bash
sudo pmset -c sleep 0
sysadminctl -screenLock status
pmset -g custom
defaults -currentHost read com.apple.screensaver idleTime
```

The pilot reported `screenLock is off`, `displaysleep 0` and `sleep 0` under **AC Power**, and a screen saver `idleTime` of `0`.

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

In the owner's browser, open [GitHub device login](https://github.com/login/device) and enter the one-time code printed by `gh`. Use an account that can read both bootstrap repositories. For [guest Orca setup](#configure-orca-in-the-guest), this account also needs access to the private guest configuration repository. Approve organization SSO if prompted. The guest CLI stores its own sign-in. [GitHub CLI sign-in](https://cli.github.com/manual/gh_auth_login)

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
The same switch activates Home Manager for `yachi8000` and installs the guest tools under `/etc/profiles/per-user/yachi8000/bin`. [Home Manager's nix-darwin module](https://nix-community.github.io/home-manager/installation/nix-darwin.html)

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

Use the IPv4 address printed by the second command for Orca pairing. After guest permissions and installations are in place, GitHub, Codex, and Tailscale sign-in require only the owner's browser approvals.
Send each fresh one-time code or Tailscale sign-in URL to the owner as copyable text in their private conversation so they can use it before it expires. Keep these enrollment values out of public chat, documentation, and logs.

## Pair the guest with Orca

Install Orca on the guest and the client Mac. Open Orca in the guest and register the CLI under **Settings → General → Orca CLI**. Add the workspace from the guest terminal. [Orca install guide](https://orca.dev/docs/install)

```bash
orca repo add --environment local --path "$HOME/workspace" --json
```

If guest Orca started before Nix activation and the `workspace` Git scan stops at the Command Line Tools prompt, quit Orca in the guest. Relaunch it from the guest Terminal with the Nix profiles first in `PATH`.

```bash
/usr/bin/open --env "PATH=/etc/profiles/per-user/yachi8000/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin" -a /Applications/Orca.app
```

After this relaunch, the pilot detected `workspace` on `main` and could open a remote terminal at the project root.

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

Generate the pairing link just before use and share it privately with the intended client only. A new link replaces the previous unused link. With up-to-date clients and servers, the link stops working after successful pairing. Each client then has a separate grant that lasts until revoked from the guest's **Shared Server Access** settings. Keep pairing links and grants out of the shared folder, repositories, logs, and chat. [Orca access and security](https://orca.dev/docs/remote-servers#access-and-security), [Orca releases](https://github.com/stablyai/orca/releases)

After adding the environment, list its projects from the host.

```bash
orca repo list --environment yachi8000
```

On the pilot, `orca environment add` succeeded using the guest's Tailscale IP, and `orca repo list` returned the guest's `workspace`.

## Configure Orca in the guest

After pairing, use the guest's GitHub sign-in to access the private [guest Orca configuration repository](https://github.com/totto2727-dotfiles/orca-macos-guest).
It holds the versioned configuration for the guest Bot, its tools and abilities, and its schedules. Follow its setup instructions.
You can enable schedules before Slack approval. Slack delivery requires the owner to approve the guest's Slack connector using the [owner connector steps](https://github.com/totto2727-dotfiles/orca-macos-guest#オーナーが登録するコネクター).
Keep local Orca state, credentials, and vault data outside Git and the Nix store.

## Set up a temporary guest vault

The flake installs the [community reyamira Pass CLI v0.20.0](https://github.com/reyamira/pass-cli/releases/tag/v0.20.0).

### Initialize the guest vault

Run this command in an unrecorded guest Terminal as `yachi8000`.
The owner enters a new master password directly in the guest, chooses whether to enable the guest login Keychain, and stores the recovery phrase privately offline.
Keep the vault and its secrets out of the terminal-mac shared folder, shell arguments, logs, and chat. [Pass CLI quick start](https://reyamira.github.io/pass-cli/01-getting-started/quick-start/)

```bash
pass-cli init --no-sync
```

### Verify guest Keychain access

After initialization, check the guest login Keychain status.

```bash
pass-cli --offline keychain status
```

If the owner skipped integration during initialization and now wants it, run `pass-cli --offline keychain enable`.
The owner enters the master password at the `Master password:` prompt in the guest Terminal and approves the Pass CLI entry in the guest login Keychain if macOS asks.
Run the status command again and check for `Password Stored: Yes`, `Backend: keychain`, and `Vault Configuration: Keychain enabled`. [Pass CLI Keychain setup](https://reyamira.github.io/pass-cli/02-guides/keychain-setup/)

If Keychain integration is enabled, check from a separate guest Terminal that the vault opens without input. An exit status of `0` confirms access.

```bash
pass-cli --offline list -q </dev/null >/dev/null 2>&1
printf 'Exit status: %s\n' "$?"
```

### Use a secret in a child process

For example, the owner can enter an approved guest GitHub token with `pass-cli --offline add github-agent`.
Pass the token to the command that needs it with debugging and shell tracing off. Child processes can inherit the variable. [Pass CLI agent integration](https://reyamira.github.io/pass-cli/02-guides/ai-agents/)

```bash
pass-cli exec --set GH_TOKEN=github-agent -- \
  gh repo view totto2727-org/workspace --json nameWithOwner --jq .nameWithOwner
```

### Use the connector CLIs

Home Manager installs the wrapped `oo` and `monid` commands from the pinned `oo` 1.9.8 and Monid 0.1.7 packages in `connector-tools.nix`.
Build the flake in the guest using the normal [activation steps](#build-and-activate-the-pinned-configuration).

Both commands read the password fields of `open-connector/url` and `open-connector/api-key` from the guest Pass CLI vault.
Keep the guest values in that vault and out of Git and the Nix store.
Monid routes requests through the connector's `/v1/passthrough/monid` endpoint and removes its private temporary configuration when it exits.

Run these checks from a guest Orca terminal before enabling scheduled jobs.

```bash
command -v oo monid
oo version --json
monid --version
monid whoami -j >/dev/null
```

If a wrapper reports a vault lookup failure, check [guest Keychain access](#verify-guest-keychain-access) and confirm that both named entries exist with a nonempty password field.
The wrappers stop if the vault requires a prompt or a value is missing.
If the commands resolve outside the guest profile, open a new login shell or restart guest Orca after activation.

### Replace the temporary vault setup

**TODO.** Evaluate these two options before replacing Pass CLI. Both need verification.

- Check whether a Keychain item can be restricted to explicitly approved apps and how to verify the restriction.
- Evaluate a proxy outside the guest that holds credentials and performs only the operations the guest needs.

## Verify the guest

- Verify the guest's inactivity settings and repeat `"$HOME/.local/bin/terminal-mac" action yachi8000 screenshot` from the host with the native window hidden.
- Confirm `id -un` returns `yachi8000` and `uname -m` returns `arm64`.
- Confirm `scutil --get ComputerName`, `scutil --get HostName`, and `scutil --get LocalHostName` all return `yachi8000`. Check that `test -x /run/current-system/sw/bin/darwin-rebuild` succeeds.
- In a fresh guest Terminal, run `command -v codex gh git jq python3 rg pass-cli oo monid`. Each path should start with `/etc/profiles/per-user/yachi8000/bin/`.
- Run `codex --version`, `gh --version`, `git --version`, `jq --version`, `python3 --version`, `rg --version`, and `pass-cli version`. Pass CLI should report `0.20.0`.
- Run `git -C "$HOME/workspace" remote get-url origin` and `git -C "$HOME/workspace/nix" remote get-url origin`. Confirm the URLs match the two clone commands. Run `gh auth status --hostname github.com` and `codex login status`.
- In the guest, run `/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4` and confirm that Orca uses that address for pairing.
- In client Orca, check that the guest server shows **Connected** and open a remote terminal in `workspace`. Confirm that guest Orca detects Codex in **Settings → Agents**. [Orca agent troubleshooting](https://orca.dev/docs/troubleshooting)

From the remote terminal, check the guest identity, workspace, and Codex sign-in.

```bash
id -un
hostname
pwd
codex login status
```

With the native VM window hidden, the pilot read back `yachi8000` as the user and hostname, `/Users/yachi8000/workspace` as the working directory, and a ChatGPT sign-in for Codex.
The pilot also checked both private Git origins and confirmed that the active `yachi8000/flake.nix` and `yachi8000/flake.lock` matched the PR.

The Apple silicon host build with `nix build --no-link` verified the generated Home Manager activation script and per-user profile without activating the configuration.
The pilot verified guest-side sign-in for GitHub CLI, Codex, and Tailscale with the browser flows above. The guest checks cover the running session.
