{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-snapd = {
      url = "https://flakehub.com/f/nix-community/nix-snapd/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      determinate,
      nixpkgs,
      home-manager,
      nix-snapd,
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            determinate.nixosModules.default
            ./configuration.nix
            nix-snapd.nixosModules.default
            {
              services.snap.enable = true;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.totto2727 =
                { pkgs, ... }:
                {
                  home.stateVersion = "25.11";

                  home.shell.enableZshIntegration = true;

                  home.packages = with pkgs; [
                    # GUI
                    xdg-user-dirs
                    # CLI
                    git
                    go-task
                    unzip
                    fakeroot
                    sqlite
                    # Lang toolchain
                    nixfmt-rfc-style
                    # TUI
                    neovim
                    # font
                    ibm-plex
                    plemoljp
                    plemoljp-hs
                    plemoljp-nf
                    # browser
                    microsoft-edge
                    # game
                    protonup-ng
                    waydroid-helper
                  ];

                  programs = {
                    zsh = {
                      enable = true;
                      enableCompletion = true;
                    };
                    starship.enable = true;
                    zoxide.enable = true;
                    git = import ../share/git.nix;
                    gh = import ../share/gh.nix;
                  };
                  home.sessionVariables = {
                    EDITOR = "nvim";
                    STEAM_EXTRA_COMPAT_TOOLS_PATHS = ''
                      ''${HOME}/.steam/root/compatibilitytools.d;
                    '';
                  };
                };
            }
          ];
        };
      };
    };
}
