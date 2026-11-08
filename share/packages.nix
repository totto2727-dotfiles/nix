{ pkgs }:
with pkgs;
[
  git
  # CLI
  eza
  ripgrep
  sd
  fd
  rename
  fzf
  bottom
  # TUI
  neovim
  lazygit
  yazi
  # Coding
  nixfmt
  just
  chezmoi
]
++ lib.optional (pkgs ? witr) pkgs.witr
++ lib.optionals stdenv.isLinux [
  monid
  oo-cli
]
