{ pkgs }:
{
  programs = {
    gpg = import ./gpg.nix;
    starship = import ./starship.nix;
  };
  services = {
    gpg-agent = import ./gpg-agent.nix { inherit pkgs; };
  };
}
