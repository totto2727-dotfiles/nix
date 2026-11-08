default:
    @just --list --list-submodules

vscode-extensions:
    code --list-extensions | jq -R -s 'split("\n") | map(select(length > 0))' > vscode/extensions.json
