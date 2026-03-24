{ pkgs, npm }:
[
  pkgs.git
  # CLI
  pkgs.eza
  pkgs.ripgrep
  pkgs.sd
  pkgs.fd
  pkgs.rename
  pkgs.fzf
  # TUI
  pkgs.lazygit
  pkgs.lazydocker
  pkgs.yazi
  # Coding
  pkgs.devbox
  pkgs.chezmoi
  pkgs.lefthook
  pkgs.go-task
  pkgs.nixfmt-rfc-style
  pkgs.duckdb
  # Runtime
  pkgs.nodejs
  pkgs.bun
  pkgs.deno
  pkgs.pnpm
  pkgs.typescript
  pkgs.typescript-language-server
  pkgs.python3
  pkgs.pyright
  pkgs.uv
  pkgs.go
  pkgs.rustup
  # npm
  (npm {
    name = "srt";
    packageName = "@anthropic-ai/sandbox-runtime";
    additionalArgs = "";
  })
  (npm {
    name = "skills";
    packageName = "skills";
  })
  (npm {
    name = "pi";
    packageName = "@mariozechner/pi-coding-agent";
  })
]
