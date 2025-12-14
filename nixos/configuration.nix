# Custom
# nix-shell -p neovim
# nix-shell -p git
# export LANG=en_US.UTF-8
# sudo nvim /etc/nixos/configuration.nix
# nix.settings.experimental-features = ["nix-command" "flakes"];
# sudo nixos-rebuild switch
# git clone ...
# cd nixos
# cp /etc/nixos/hardware-configuration.nix .
# sudo nixos-rebuild switch --flake .#nixos
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # services.openssh.enable = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager = {
    autoLogin.user = "totto2727";
    cosmic-greeter.enable = true;
  };
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    mangohud
    cosmic-store
  ];

  users.groups = {
    nordvpn = {
      gid = null;
    };
  };
  users.users.totto2727 = {
    isNormalUser = true;
    description = "totto2727";
    extraGroups = [
      "networkmanager"
      "wheel"
      "nordvpn"
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
}
