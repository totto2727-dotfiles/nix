{
  description = "A flake to provision my environment";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
      home-manager,
      nix-darwin,
    }:
    let
      hostname = "totto2727";
      username = "totto2727";
      homedir = "/Users/${username}";
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      nixpkgs.config.allowUnfree = true;
      darwinConfigurations = {
        "${hostname}" = nix-darwin.lib.darwinSystem {
          inherit system pkgs;

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
                  "gemini-cli"
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
                  "claude"
                  "claude-code"
                  "podman-desktop"
                  "ghostty"
                  # Utility
                  "1password"
                  "Logi-options+"
                  "raycast"
                  "cleanmymac"
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
                  pkgs.eza
                  pkgs.ripgrep
                  pkgs.sd
                  pkgs.fd
                  # Formulae Coding
                  pkgs.go-task
                  pkgs.chezmoi
                  pkgs.nixfmt-rfc-style
                  pkgs.ni
                  # Formulae Runtime
                  pkgs.nodejs
                  pkgs.pnpm
                  pkgs.bun
                  pkgs.deno
                  # Formulae TUI
                  pkgs.lazygit
                  pkgs.lazydocker
                  pkgs.yazi
                  # Cask
                  pkgs.pinentry_mac
                ];
                programs.gpg = {
                  enable = true;
                };
                services.gpg-agent = {
                  enable = true;
                  pinentry.package = pkgs.pinentry_mac;
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
                      src = pkgs.fetchFromGitHub {
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
                programs.starship = {
                  enable = true;
                };
                programs.git = {
                  enable = true;
                  ignores = [
                    "**/.totto/"
                    "**/.DS_Store"
                    "**/*.local*"
                    "!**/*.local.template*"

                  ];
                  settings = {
                    user = {
                      name = "totto2727";
                      email = "kaihatu.totto2727@gmail.com";
                    };
                    pull = {
                      rebase = true;
                    };
                    core = {
                      ignorecase = false;
                    };
                    init = {
                      defaultBranch = "main";
                    };
                    merge = {
                      conflictstyle = "zdiff3";
                    };
                  };
                  includes = [
                    {
                      path = "~/.gitconfig";
                    }
                  ];
                };
                programs.gh = {
                  enable = true;
                  gitCredentialHelper.enable = true;
                };
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
