{
  description = "A flake to provision my environment";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    npmpkgs = {
      url = "github:netbrain/npm-package";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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
      hostname = "totto2727";
      username = "totto2727";
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
            (
              { ... }:
              {
                nix.enable = false;
              }
            )
            {
              system = {
                stateVersion = 5;
                primaryUser = "totto2727";
              };
              homebrew = {
                enable = true;
                onActivation = {
                  autoUpdate = true;
                  cleanup = "uninstall";
                  upgrade = true;
                };
                taps = [
                  "slp/krunkit"
                ];
                brews = [
                  "podman"
                  "slp/krunkit/krunkit"
                  # for v2
                  "lima"
                  "mas"
                ];
                casks = [
                  # Font
                  "font-plemol-jp"
                  "font-plemol-jp-nf"
                  # Browser
                  "google-chrome"
                  "microsoft-edge"
                  # Coding
                  "antigravity"
                  "podman-desktop"
                  "ghostty"
                  # Utility
                  "1password"
                  "Logi-options+"
                  "raycast"
                  "cleanmymac"
                  "discord"
                  "slack"
                  "notion"
                  "notion-mail"
                  "notion-calendar"
                ];
                masApps = {
                  "Kindle" = 302584613;
                  "Mp3tag" = 1532597159;
                  "Prime Video" = 545519333;
                  "Slack" = 803453959;
                  "Tailscale" = 1475387142;
                };
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
                home.packages = [
                  # Formulae CLI
                  nix.eza
                  nix.ripgrep
                  nix.sd
                  nix.fd
                  # Formulae Coding
                  nix.chezmoi
                  nix.lefthook
                  nix.go-task
                  nix.nixfmt-rfc-style
                  nix.ni
                  nix.turbo
                  # Formulae Runtime
                  nix.devbox
                  nix.nodejs
                  nix.pnpm
                  nix.bun
                  nix.deno
                  nix.python3
                  nix.uv
                  # Formulae TUI
                  nix.lazygit
                  nix.lazydocker
                  nix.yazi
                  # Cask
                  nix.pinentry_mac
                  (npm {
                    name = "sfw";
                    packageName = "sfw";
                  })
                ];
                programs.gpg = {
                  enable = true;
                };
                services.gpg-agent = {
                  enable = true;
                  pinentry.package = nix.pinentry_mac;
                };
                programs.neovim = {
                  enable = true;
                };
                programs.zsh = {
                  enable = true;
                  enableCompletion = true;
                  initContent = ''
                                eval "$(/opt/homebrew/bin/brew shellenv)"
                                chpwd() {
                                  eza -a --group-directories-first
                                }
                    	      '';
                  plugins = [
                    {
                      name = "by-binds-yourself";
                      file = "by.zsh";
                      src = nix.fetchFromGitHub {
                        owner = "atusy";
                        repo = "by-binds-yourself";
                        rev = "v1.0.0";
                        sha256 = "sha256-x2wwlWH4QAR6NnohIZKm6YarbiZnNPJBDd/r6XqZKP4=";
                      };
                    }
                  ];
                  shellAliases = {
                    la = "eza -a --group-directories-first";
                    ll = "la -l";
                    vi = "nvim";
                    vim = "nvim";
                    VI = "nvim";
                    LG = "lazygit";
                    LD = "lazydocker";
                    YZ = "yazi";
                    P = "podman.lima";
                    G = "git";
                    GB = "git branch";
                    GC = "git commit";
                    GCA = "git commit --amend";
                    GSW = "git switch";
                    GSWC = "git switch -c";
                    GPUSHF = "git push --force-with-lease --force-if-includes";
                    gh-pr-create = "gh pr create -a '@me' --base";
                    path-list = ''
                      "echo "$PATH" | sd ':' '\n'"
                    '';
                  };
                };
                programs.direnv = {
                  enable = true;
                };
                programs.starship = {
                  enable = true;
                };
                programs.git = import ../share/git.nix;
                programs.gh = import ../share/gh.nix;
                programs.delta = {
                  enable = true;
                  enableGitIntegration = true;
                };
                programs.lazygit = {
                  enable = true;
                  enableZshIntegration = true;
                  settings = {
                    git = {
                      pagers = [
                        {
                          colorArg = "always";
                          pager = "delta --dark --paging=never";
                        }
                      ];
                    };
                  };
                };
                programs.zoxide = {
                  enable = true;
                  enableZshIntegration = true;
                };
                home.sessionVariables = {
                  EDITOR = "nvim";
                };
                home.sessionPath = [
                  "$HOME/.local/bin"
                  "$HOME/.antigravity/antigravity/bin"
                ];
              };
            }
          ];
        };
      };
    };
}
