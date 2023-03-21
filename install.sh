#!/bin/sh

zshrc() {
    echo "==========================================================="
    echo "                  Import zshrc                             "
    echo "-----------------------------------------------------------"
    cat .zshrc >> $HOME/.zshrc
    cp schminitz-v2.zsh-theme $HOME/.oh-my-zsh/themes/schminitz-v2.zsh-theme
}

zshrc