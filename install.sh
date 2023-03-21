#!/bin/sh

zshrc() {
    echo "==========================================================="
    echo "                cloning zsh-autosuggestions                "
    echo "-----------------------------------------------------------"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    echo "==========================================================="
    echo "                       cloning theme                       "
    echo "-----------------------------------------------------------"
    git clone --depth=1 https://github.com/mashdots/schminitz-v2.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/schminitz-v2

    echo "==========================================================="
    echo "                       cloning pyenv                       "
    echo "-----------------------------------------------------------"
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv

    echo "==========================================================="
    echo "                       Import zshrc                        "
    echo "-----------------------------------------------------------"
    cp .zshrc $HOME/.zshrc
}

zshrc