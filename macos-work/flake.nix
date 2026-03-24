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
                primaryUser = "hayato.tsuchida";
              };
              homebrew = {
                enable = true;
                onActivation = {
                  autoUpdate = true;
                  cleanup = "uninstall";
                  upgrade = true;
                };
                taps = [
                  "neurosnap/tap"
                  "slp/krun"
                ];
                brews = [
                  "zmx"
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
                  "font-ibm-plex-sans-jp"
                  "font-plemol-jp"
                  "font-plemol-jp-nf"
                  # Browser
                  "google-chrome"
                  # Coding
                  "visual-studio-code"
                  "cursor"
                  "claude-code"
                  "ghostty"
                  "claude"
                  "podman-desktop"
                  "figma"

                  # Utility
                  "thaw"
                  "slack"
                  "macs-fan-control"
                  "postman"
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
                home.sessionVariables = {
                  EDITOR = "nvim";
                  TERM = "xterm-256color";
                  GITHUB_PERSONAL_ACCESS_TOKEN = "$(gh auth token)";
                  CONTEXT7_API_KEY = "$(security find-generic-password -s CONTEXT7_API_KEY -a CONTEXT7_API_KEY -w)";
                  CLOUDFLARE_ACCOUNT_ID = "$(security find-generic-password -s CLOUDFLARE_ACCOUNT_ID -a CLOUDFLARE_ACCOUNT_ID -w)";
                  CLOUDFLARE_MARKDOWN_API_KEY = "$(security find-generic-password -s CLOUDFLARE_MARKDOWN_API_KEY -a CLOUDFLARE_MARKDOWN_API_KEY -w)";
                };
                home.sessionPath = [
                  "$HOME/.local/bin"
                  "$HOME/.deno/bin"
                  "$HOME/.moon/bin"
                  "$HOME/.vite-plus/bin"
                ];
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
                  nix.git-cliff
                  # Formulae Runtime
                  nix.nodejs
                  nix.bun
                  nix.deno
                  nix.pnpm
                  nix.typescript
                  nix.typescript-language-server
                  nix.python3
                  nix.pyright
                  nix.uv
                  nix.go
                  nix.krunkit
                  nix.podman
                  nix.docker
                  # GUI
                  nix.pinentry_mac
                  nix.kanata-with-cmd
                  # npm
                  (npm {
                    name = "srt";
                    packageName = "@anthropic-ai/sandbox-runtime";
                    additionalArgs = "";
                  })
                  (npm {
                    name = "skills";
                    packageName = "skills";
                  })
                  (npm {
                    name = "pi";
                    packageName = "@mariozechner/pi-coding-agent";
                  })
                ];
                programs.zsh = {
                  enable = true;
                  enableCompletion = true;
                  initContent = ''
                                eval "$(/opt/homebrew/bin/brew shellenv)"

                                # Vite+
                                [ -f "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"

                                if [[ -n "$CLAUDECODE" || ! -o interactive ]]; then
                                  return
                                fi

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
                      echo "$PATH" | sd ':' '\n'
                    '';
                    kanata = "sudo kanata -c $HOME/.config/kanata/kanata.kbd";
                    karabiner = "sudo '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'";
                    pacli = ''
                      /Applications/Prisma\ Access\ Agent.app/Contents/Helpers/pacli
                    '';
                  };
                };
                programs.direnv = {
                  enable = true;
                };
                programs.starship = {
                  enable = true;
                };
                programs.zoxide = {
                  enable = true;
                  enableZshIntegration = true;
                };
                programs.neovim = {
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
                programs.gpg = {
                  enable = true;
                };
                services.gpg-agent = {
                  enable = true;
                  pinentry.package = nix.pinentry_mac;
                };
              };
            }
          ];
        };
      };
    };
}
