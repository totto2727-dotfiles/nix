{ pkgs }:
{
  enable = true;
  extensions = [ pkgs.gh-poi ] ++ pkgs.lib.optional (pkgs ? gh-stack) pkgs.gh-stack;
  gitCredentialHelper.enable = true;
}
