{
  description = "System configuration for an Apple silicon macOS guest";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { home-manager, nix-darwin, ... }:
    let
      username = "yachi8000";
    in
    {
      darwinConfigurations.macos-ai = nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.home-manager
          (
            { pkgs, ... }:
            let
              pass-cli = pkgs.stdenvNoCC.mkDerivation rec {
                pname = "pass-cli";
                version = "0.20.0";
                src = pkgs.fetchurl {
                  url = "https://github.com/reyamira/pass-cli/releases/download/v${version}/pass-cli_${version}_darwin_all.tar.gz";
                  hash = "sha256-jd8EimQmXOWnUZc/LlHtO2aaOBibxOEtd6A6mtrWv88=";
                };
                sourceRoot = ".";
                dontBuild = true;
                dontStrip = true;
                installPhase = ''
                  runHook preInstall
                  install -Dm755 pass-cli "$out/bin/pass-cli"
                  runHook postInstall
                '';
              };
            in
            {
              nixpkgs.hostPlatform = "aarch64-darwin";
              nix.enable = false; # The Determinate installer owns Nix.

              networking.hostName = "macos-ai";
              networking.localHostName = "macos-ai";
              system.primaryUser = username;
              system.stateVersion = 7;
              time.timeZone = "Asia/Tokyo";

              users.users.${username}.home = "/Users/${username}";
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = {
                  home.stateVersion = "25.11";
                  manual.manpages.enable = false;
                  home.packages = with pkgs; [
                    codex
                    gh
                    gitMinimal
                    jq
                    pass-cli
                    python3
                    ripgrep
                  ];
                };
              };
            }
          )
        ];
      };
    };
}
