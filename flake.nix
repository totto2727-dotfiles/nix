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
                brews = [
                  "lima"
                  "gemini-cli"
                ];
                casks = [
                  "font-plemol-jp"
                  "font-plemol-jp-nf"
                  "antigravity"
                  "claude-code"
                  "microsoft-edge"
                  "Logi-options+"
                  "1password"
                  "raycast"
                  "podman-desktop"
                ];
                masApps = { };
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
                  pkgs.nixfmt-rfc-style
                  pkgs.go-task
                  pkgs.pinentry_mac
                  pkgs.git
                  pkgs.gh
                  pkgs.starship
                  pkgs.ghostty-bin
                  pkgs.chezmoi
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
                    	      '';
                  shellAliases = {
                    ll = "ls -al";
                    vi = "nvim";
                    vim = "nvim";
                    VI = "nvim";
                  };
                };
                programs.starship = {
                  enable = true;
                };
                programs.git = {
                  enable = true;
		  settings = {
			  user = {
			    name = "totto2727";
			    email = "kaihatu.totto2727@gmail.com";
			  };
		  };
                };
		programs.gh = {
		 enable = true;
		 gitCredentialHelper.enable = true;
		};
              };
            }
          ];
        };
      };
    };
}
