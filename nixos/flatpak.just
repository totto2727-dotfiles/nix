default:
    @just --list --list-submodules

install:
    flatpak install app.zen_browser.zen
    flatpak install flathub com.github.tchx84.Flatseal
