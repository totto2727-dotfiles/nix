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
      nix-darwin,
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

            home.sessionVariables = {
              EDITOR = "nvim";
            };

            home.sessionPath = [
              "$HOME/.local/bin"
              "$HOME/.deno/bin"
              "$HOME/.moon/bin"
              "$HOME/.vite-plus/bin"
            ];

            programs = {
              home-manager.enable = true;
              direnv.enable = true;
              starship.enable = true;
              neovim.enable = true;
              git = import ../share/git.nix;
              gh = import ../share/gh.nix;
              zoxide = {
                enable = true;
                enableZshIntegration = true;
              };
              zsh = {
                enable = true;
                enableCompletion = true;

                initContent = ''
                          eval "$(devbox global shellenv --init-hook)"
                          [ -f "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"
                  	      '';

                shellAliases = {
                  home-manager = "home-manager --flake ~/nix/sandbox#sandbox";
                  chezmoi = "chezmoi --source ~/chezmoi";
                };
              };
            };

            home.packages = with pkgs; [
              # minimal dependency
              gcc
              # minimal development
              git
              devbox
              chezmoi
              go-task
              # development
              nodejs
              bun
              deno
              pnpm
              python3
              uv
              go
              (npm {
                name = "skills";
                packageName = "skills";
              })
              (npm {
                name = "pi";
                packageName = "@mariozechner/pi-coding-agent";
              })
            ];
          }
        ];
      };
    };
}
