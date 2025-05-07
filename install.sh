#!/bin/sh

setup() {
    echo "==========================================================="
    echo "                cloning zsh-autosuggestions                "
    echo "-----------------------------------------------------------"
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    git clone https://github.com/mattmc3/zshrc.d $ZSH_CUSTOM/plugins/zshrc.d
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

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
    cp lib $HOME/zshrc.d
    cp .zshrc $HOME/.zshrc
}

setup