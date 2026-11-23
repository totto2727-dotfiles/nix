{ pkgs, npm }:
with pkgs;
[
  git
  # CLI
  witr
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
  # Coding
  nixfmt
  just
  chezmoi
]
