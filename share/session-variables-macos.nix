{ homedir }:
(import ./session-variables.nix)
// {
  XDG_CONFIG_HOME = "${homedir}/.config/";
}
