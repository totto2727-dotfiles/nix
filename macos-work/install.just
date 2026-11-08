default:
    @just --list --list-submodules

vscode-extensions:
    jq -r '.[]' ./vscode/extensions.json | xargs -I {} code --install-extension {}
