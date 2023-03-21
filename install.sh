#!/bin/sh

zshrc() {
    echo "==========================================================="
    echo "                cloning zsh-autosuggestions                "
    echo "-----------------------------------------------------------"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions

    echo "==========================================================="
    echo "                     installing theme                      "
    echo "-----------------------------------------------------------"
    git clone --depth=1 https://github.com/mashdots/schminitz-v2.git
    cp schminitz-v2/schminitz-v2.zsh-theme ~/.oh-my-zsh/themes/schminitz-v2.zsh-theme

    echo "==========================================================="
    echo "                       cloning pyenv                       "
    echo "-----------------------------------------------------------"
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv

    echo "==========================================================="
    echo "                       import zshrc                        "
    echo "-----------------------------------------------------------"
    cp .zshrc $HOME/.zshrc
}

zshrc