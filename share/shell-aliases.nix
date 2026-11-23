{
  la = "eza -a --group-directories-first";
  ll = "la -l";
  vi = "nvim";
  vim = "nvim";
  LG = "lazygit";
  GC = "git commit";
  GCA = "git commit --amend";
  GSW = "git switch";
  GSWC = "git switch -c";
  GPUSHF = "git push --force-with-lease --force-if-includes";
  path-list = ''
    echo "$PATH" | sd ':' '\n'
  '';
}
