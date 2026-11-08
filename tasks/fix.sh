#!/usr/bin/env bash
set -euo pipefail

git ls-files --cached --others --exclude-standard -z -- '*.nix' | xargs -0 nixfmt
