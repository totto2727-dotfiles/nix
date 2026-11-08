{ pkgs }:
let
  app =
    name: dependencies: script:
    let
      command = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ pkgs.coreutils ] ++ dependencies;
        text = ''
          if [[ ! -f share/packages/flake.nix || ! -f tasks/default.nix ]]; then
            echo "Run this command from the dotfiles repository root." >&2
            exit 1
          fi
        ''
        + builtins.readFile script;
      };
    in
    {
      type = "app";
      program = "${command}/bin/${name}";
    };
  formatDependencies = [
    pkgs.git
    pkgs.findutils
    pkgs.nixfmt
  ];
in
{
  apps = {
    check = app "check" formatDependencies ./check.sh;
    fix = app "fix" formatDependencies ./fix.sh;
    update = app "update" [ ] ./update.sh;
    rebuild = app "rebuild" [ ] ./rebuild.sh;
    default = app "help" [ ] ./help.sh;
  };
}
