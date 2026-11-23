{
  username,
  homedir,
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # The macOS flakes replace the outer home-manager attribute with host settings.
  imports = [
    {
      home-manager.sharedModules = [
        {
          home.file.".npmrc".text = ''
            registry=https://npm.flatt.tech
          '';
        }
      ];
    }
  ];
  users.users.${username}.home = homedir;
}
