{
  description = "A flake to provision my environment";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2511";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npmpkgs = {
      url = "https://flakehub.com/f/totto2727-dotfiles/npm-packages/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      npmpkgs,
      home-manager,
    }:
    let
      pkgs = import nixpkgs {
        system = "arm64-linux";
      };
      npm = npmpkgs.lib.${pkgs.system}.npmPackage;
    in
    {
      nixpkgs.config.allowUnfree = true;
      homeConfigurations.sandbox = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          {
            home.stateVersion = "25.11";

            home.username = "sandbox";
            home.homeDirectory = "/sandbox";

            home.packages = import ../share/packages.nix { inherit pkgs npm; };

            programs = {
              home-manager.enable = true;
              direnv = import ../share/direnv.nix;
              zoxide = import ../share/zoxide.nix;
              starship = import ../share/starship.nix;
              neovim = import ../share/neovim.nix;
              git = import ../share/git.nix;
              gh = import ../share/gh.nix;
              delta = import ../share/delta.nix;
              lazygit = import ../share/lazygit.nix;
              zsh = {
                enable = true;
                enableCompletion = true;

                initContent = ''
                          eval "$(devbox global shellenv --init-hook)"
                          [ -f "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"
                  	      '';

                shellAliases = (import ../share/shell-aliases.nix) // {
                  home-manager = "home-manager --flake ~/nix/sandbox#sandbox";
                  chezmoi = "chezmoi --source ~/chezmoi";
                };
              };
            };

            home.sessionVariables = {
              EDITOR = "nvim";
            };

            home.sessionPath = import ../share/session-path.nix;
          }
        ];
      };
    };
}
