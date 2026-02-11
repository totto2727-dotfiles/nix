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
      url = "github:netbrain/npm-package";
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
      hostname = "totto2727-macos";
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
                  "lima"
                  "mas"
                  "tailscale"
                  "incus"
                  "talosctl"
                  # Gnu
                  "coreutils"
                  "grep"
                  "gnu-sed"
                  "watch"
                  "diffutils"
                  "findutils"
                  "gawk"
                  "gnu-which"
                  "less"
                  "gzip"
                  "gpatch"
                  "zip"
                  "wget"
                  "wdiff"
                  "gnu-tar"
                ];
                casks = [
                  # Font
                  "font-plemol-jp"
                  "font-plemol-jp-nf"
                  # Browser
                  "google-chrome"
                  "zen"
                  # Coding
                  "claude-code"
                  "zed"
                  "antigravity"
                  "podman-desktop"
                  "ghostty"
                  # Game
                  "heroic"
                  # Utility
                  "1password"
                  "Logi-options+"
                  "raycast"
                  "cleanmymac"
                  "discord"
                  "slack"
                  "notion"
                  "notion-calendar"
                  "balenaetcher"
                  "karabiner-elements"
                  "thaw"
                ];
                masApps = {
                  "Kindle" = 302584613;
                  "Mp3tag" = 1532597159;
                  "Prime Video" = 545519333;
                  "Slack" = 803453959;
                  "Tailscale" = 1475387142;
                  "Steam Link" = 1246969117;
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
                  nix.rename
                  nix.fzf
                  # Formulae TUI
                  nix.lazygit
                  nix.lazydocker
                  nix.yazi
                  # Formulae Coding
                  nix.devbox
                  nix.chezmoi
                  nix.lefthook
                  nix.go-task
                  nix.nixfmt-rfc-style
                  nix.duckdb
                  # Formulae Runtime
                  nix.nodejs
                  nix.bun
                  nix.deno
                  nix.typescript
                  nix.typescript-language-server
                  nix.go
                  nix.gopls
                  nix.air
                  nix.python3
                  nix.pyright
                  nix.uv
                  nix.rustup
                  nix.dotnet-sdk
                  # nix.moonbit?
                  # GUI
                  nix.pinentry_mac
                  nix.kanata-with-cmd
                  # npm
                  (npm {
                    name = "pnpm";
                    packageName = "pnpm";
                  })
                  (npm {
                    name = "oxlint";
                    packageName = "oxlint";
                  })
                  (npm {
                    name = "oxfmt";
                    packageName = "oxfmt";
                  })
                  (npm {
                    name = "@biomejs/biome";
                    packageName = "biome";
                  })
                  (npm {
                    name = "turbo";
                    packageName = "turbo";
                  })
                  (npm {
                    name = "skills";
                    packageName = "skills";
                  })
                  (npm {
                    name = "ccstatusline";
                    packageName = "ccstatusline";
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
                                source ~/.safe-chain/scripts/init-posix.sh
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
                      echo "$PATH" | sd ':' '\n'
                    '';
                    kanata = "sudo kanata -c $HOME/.config/kanata/kanata.kbd";
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
                  TERM = "xterm-256color";
                  ENABLE_LSP_TOOL = 1;
                  GITHUB_PERSONAL_ACCESS_TOKEN = "$(gh auth token)";
                };
                home.sessionPath = [
                  "$HOME/.local/bin"
                  "$HOME/.deno/bin"
                  "$HOME/.antigravity/antigravity/bin"
                  "$HOME/.moon/bin" # moonbit
                ];
              };
            }
          ];
        };
      };
    };
}
