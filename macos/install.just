set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list --list-submodules

jcode:
    curl -fsSL https://jcode.sh/install | bash

moonbit:
    curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

vite-plus:
    curl -fsSL https://vite.plus | bash
