# Raspberry Pi manual setup

This guide is for maintainers of the Raspberry Pi running an APT-based distribution.
It is separate from the four Nix host targets and has no root rebuild target.
The commands run on the Pi after the initial SSH connection.

## Network and Tailscale

Connect to the Pi and configure Wi-Fi interactively:

```bash
ssh totto2727@totto2727-raspi
sudo nmcli dev wifi connect totto2727 --ask
```

Review the [official Tailscale installer](https://tailscale.com/install.sh) before executing it.

```bash
sudo apt install ufw wakeonlan
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh
```

Keep the current SSH session open and verify a second connection through Tailscale before changing firewall rules or disabling the existing SSH service.
Allow the management traffic required by the host before enabling UFW.
Enabling a firewall without a tested access rule can disconnect the host.

```bash
sudo systemctl enable ufw
sudo ufw enable
```

Only after Tailscale SSH and firewall access are verified, disable the conventional SSH service if it is no longer needed:

```bash
sudo systemctl disable sshd
```

Check the service name on the installed distribution first.
Disabling a service does not stop its current process.
