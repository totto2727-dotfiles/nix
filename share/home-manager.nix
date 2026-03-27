{
  username,
  homedir,
  stateVersion,
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  users.users.${username}.home = homedir;
  home-manager.users.${username} = {
    home.stateVersion = stateVersion;
  };
}
