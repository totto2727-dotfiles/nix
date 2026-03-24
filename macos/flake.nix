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
            {
              nix.enable = false;
            }
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
                taps = import ../share/taps.nix;
                brews = (import ../share/brews.nix) ++ [
                  "mas"
                  "tailscale"
                  "incus"
                  "talosctl"
                ];
                casks = (import ../share/casks.nix) ++ [
                  # Browser
                  "zen"
                  # Coding
                  "zed"
                  "orbstack"
                  # Game
                  "heroic"
                  # Utility
                  "nordvpn"
                  "1password"
                  "Logi-options+"
                  "raycast"
                  "cleanmymac"
                  "discord"
                  "notion-calendar"
                  "balenaetcher"
                ];
                masApps = {
                  "Kindle" = 302584613;
                  "Mp3tag" = 1532597159;
                  "Prime Video" = 545519333;
                  "Slack for Desktop" = 803453959;
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
                home.packages = (import ../share/packages.nix { pkgs = nix; inherit npm; }) ++ [
                  nix.gopls
                  nix.air
                  nix.dotnet-sdk
                  nix.zig
                  nix.pinentry_mac
                  nix.kanata-with-cmd
                ];
                programs.direnv = import ../share/direnv.nix;
                programs.zoxide = import ../share/zoxide.nix;
                programs.starship = import ../share/starship.nix;
                programs.neovim = import ../share/neovim.nix;
                programs.gpg = import ../share/gpg.nix;
                services.gpg-agent = import ../share/gpg-agent.nix { pkgs = nix; };
                programs.git = import ../share/git.nix;
                programs.gh = import ../share/gh.nix;
                programs.delta = import ../share/delta.nix;
                programs.lazygit = import ../share/lazygit.nix;
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
                  shellAliases = (import ../share/shell-aliases.nix) // (import ../share/shell-aliases-macos.nix);
                };
                home.sessionVariables = {
                  EDITOR = "nvim";
                  TERM = "xterm-256color";
                  GITHUB_PERSONAL_ACCESS_TOKEN = "$(gh auth token)";
                  CONTEXT7_API_KEY = "$(security find-generic-password -s CONTEXT7_API_KEY -a CONTEXT7_API_KEY -w)";
                  CLOUDFLARE_ACCOUNT_ID = "$(security find-generic-password -s CLOUDFLARE_ACCOUNT_ID -a CLOUDFLARE_ACCOUNT_ID -w)";
                  CLOUDFLARE_MARKDOWN_API_KEY = "$(security find-generic-password -s CLOUDFLARE_MARKDOWN_API_KEY -a CLOUDFLARE_MARKDOWN_API_KEY -w)";
                };
                home.sessionPath = import ../share/session-path.nix;
              };
            }
          ];
        };
      };
    };
}
