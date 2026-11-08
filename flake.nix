{
  description = "Standalone workstation and server configuration";

  inputs = {
    local-packages.url = "path:./share/packages";
    nixpkgs.follows = "local-packages/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      tasksFor = system: import ./tasks/default.nix { pkgs = nixpkgs.legacyPackages.${system}; };
    in
    {
      apps = forAllSystems (system: (tasksFor system).apps);
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShellNoCC {
          packages = [ nixpkgs.legacyPackages.${system}.nixfmt ];
        };
      });
    };
}
