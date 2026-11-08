default:
    @just --list --list-submodules

install:
    curl -L https://cmux.com/api/download/browser-nightly/linux-x64/run > ~/Downloads/cmux-linux-x64-installer.run
    chmod +x ~/Downloads/cmux-linux-x64-installer.run
    ~/Downloads/cmux-linux-x64-installer.run
