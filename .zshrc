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
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_PROFILE=dev
export AWS_REGION=us-west-2
export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-20250514-v1:0

# Path setup
export PATHARRAY=(
  "$PYENV_ROOT/bin"
  # "/bin/bash"
  "$HOME/.local/bin"
  "$WORKSPACE/venv/bin"
)
declare -a error_paths

for i in "${PATHARRAY[@]}"; do
  if [[ -d $i ]]; then
    export PATH="$PATH:$i"
  else
    error_paths+=($i)
  fi
done

# If there are any errors in the PATHARRAY, print them out
if [[ ${#error_paths[@]} -gt 0 ]]; then
  printf "\n$fg[red]The following paths failed to initialize:$reset_color\n\n"
  for i in "${error_paths[@]}"; do
    printf " > $fg[blue]$i$reset_color\n"
  done
fi

eval "$(pyenv init -)"

source $WORKSPACE/venv/bin/activate