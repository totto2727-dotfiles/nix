{
  description = "A flake to provision my environment";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
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
      hostname = "AMADH5CQH14H3";
      username = "hayato.tsuchida";
      homedir = "/Users/${username}";
      system = "aarch64-darwin";
      nix = import nixpkgs {
        inherit system;
      };
      npm = npmpkgs.lib.${nix.system}.npmPackage;
    in
    {
      nixpkgs.config.allowUnfree = true;
      darwinConfigurations = {
        "${hostname}" = nix-darwin.lib.darwinSystem {
          inherit system;

          pkgs = nix;

          modules = [
            {
              nix.enable = false;
            }
            {
              system = {
                stateVersion = 5;
                primaryUser = username;
              };
              homebrew = {
                enable = true;
                onActivation = {
                  autoUpdate = true;
                  cleanup = "uninstall";
                  upgrade = true;
                };
                taps = (import ../share/taps.nix) ++ [
                  "slp/krun"
                  "arimxyer/homebrew-tap"
                ];
                brews = import ../share/brews.nix;
                casks = (import ../share/casks.nix) ++ [
                  # Coding
                  "visual-studio-code"
                  "cursor"
                  "podman-desktop"
                  "figma"
                  "postman"
                  # Utility
                  "slack"
                ];
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              users.users.${username}.home = homedir;
              home-manager.users."${username}" = {
                home.stateVersion = "25.11";
                home.username = username;
                home.packages =
                  (import ../share/packages.nix {
                    pkgs = nix;
                    inherit npm;
                  })
                  ++ (import ../share/packages-macos.nix { pkgs = nix; })
                  ++ [
                    nix.krunkit
                    nix.podman
                    nix.docker
                  ];
                programs =
                  (import ../share/programs.nix) // (import ../share/programs-macos.nix { pkgs = nix; }).programs;
                services = (import ../share/programs-macos.nix { pkgs = nix; }).services;
                programs.zsh = (import ../share/zsh.nix { pkgs = nix; }) // {
                  initContent = ''
                                eval "$(/opt/homebrew/bin/brew shellenv)"

                                # Vite+
                                [ -f "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"

                                GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)";
                                CONTEXT7_API_KEY="$(pass-cli get context7/apikey --quiet -f password)";
                                CLOUDFLARE_ACCOUNT_ID="$(security find-generic-password -s CLOUDFLARE_ACCOUNT_ID -a CLOUDFLARE_ACCOUNT_ID -w)";
                                CLOUDFLARE_MARKDOWN_API_KEY="$(security find-generic-password -s CLOUDFLARE_MARKDOWN_API_KEY -a CLOUDFLARE_MARKDOWN_API_KEY -w)";

                                if [[ -n "$CLAUDECODE" || ! -o interactive ]]; then
                                  return
                                fi

                                chpwd() {
                                  eza -a --group-directories-first
                                }
                    	      '';
                  shellAliases =
                    (import ../share/shell-aliases.nix)
                    // (import ../share/shell-aliases-macos.nix)
                    // {
                      pacli = ''
                        /Applications/Prisma\ Access\ Agent.app/Contents/Helpers/pacli
                      '';
                    };
                };
                home.sessionVariables = {
                  EDITOR = "nvim";
                  TERM = "xterm-256color";
                };
                home.sessionPath = import ../share/session-path.nix;
              };
            }
          ];
        };
      };
    };
}
