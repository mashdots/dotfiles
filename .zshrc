ZSH_THEME="schminitz-v2"
plugins=(
  git
  npm
  node
  sudo
  wd
  vscode
  zsh-autosuggestions
  zshrc.d
)
export ZSH=$HOME/.oh-my-zsh
export WORKSPACE=${WORKSPACE:-'/workspaces/web'}
source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"
export PRE_COMMIT_ENABLED=true

export PATHARRAY=(
  "$PYENV_ROOT/bin"
  "/bin/bash"
  "$HOME/.local/bin"
)

for i in "${PATHARRAY[@]}"; do
  if [[ -d $i ]]; then
    export PATH="$PATH:$i"
  fi
done

eval "$(pyenv init -)"
