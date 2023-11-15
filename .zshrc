# ------------------------------------------------------ Exports -------------------------------------------------------
ZSH_THEME="schminitz-v2"
plugins=(git npm node sudo wd vscode zsh-autosuggestions)
export ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"
export PRE_COMMIT_ENABLED=true

export PATHARRAY=(
  "$PYENV_ROOT/bin:$PATH"
  "/bin/bash"
  "$HOME/.local/bin"
)

for i in "${PATHARRAY[@]}"; do
  if [[ -d $i ]]; then
    export PATH="$PATH:$i"
  fi
done

eval "$(pyenv init -)"
unalias delete-codespace

# ------------------------------------------------------ Aliases -------------------------------------------------------

alias thisBranch="git branch | grep '^\*' | cut -d' ' -f2" #        shows text for current branch of current directory #
alias darker="python -mdarker --config ./pyproject.toml --isort --revision master... src/aplaceforrover"
alias prs="gh pr list --author mashdots" #                                               list my current PRs in Github #
alias mypy=`dc run --workdir /web --rm --no-deps web mypy --show-error-codes src/aplaceforrover` #            run mypy #

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# ----------------------------------------------------- Functions ------------------------------------------------------

commit() { # <-- Wrapper for git commit with a message for the current branch
  local message="$*"
  if ((${#message} > 0)); then
    git commit -m "[`thisBranch`] $message"
  else
    echo "you need to append a commit message"
  fi
}

delete-codespace() {
  printf "$fg[green]Delete$reset_color this codespace? (y to confirm)?\n‣ "

  read response

  [[ $response = "y" ]] && gh cs delete -c $CODESPACE_NAME

}

function goodbye {
  printf "$fg[green]Delete$reset_color this codespace? (y to confirm)?\n‣ "

  read response

  [[ $response = "y" ]] && gh cs delete -c $CODESPACE_NAME

}

update-staging() { # <-- Wrapper for git push to staging
  git push --force origin `thisBranch`:staging-josh
}

update-branch(){ # <-- Update the current branch with the latest changes from master
  local CURRENT_BRANCH=`thisBranch`
  local MASTER="master"

  if [[ $CURRENT_BRANCH != $MASTER ]]; then
    git checkout $MASTER && git pull && git checkout $CURRENT_BRANCH && git rebase -i origin/master
  else
    printf "$fg[red]you can't update the master branch$reset_color\n"
  fi
}
