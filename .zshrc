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

# ------------------------------------------------------ Aliases -------------------------------------------------------

alias thisBranch="git branch | grep '^\*' | cut -d' ' -f2" #        shows text for current branch of current directory #
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

function blacken() {
  if [[ -f $1 ]]; then
    black --config ./pyproject.toml $1
  else
    printf "$fg[red]WHOOPS$reset_color - you need to provide a file to format.\n"
  fi
}

function commit() { # <-- Wrapper for git commit with a message for the current branch
  local message="$*"
  if ((${#message} > 0)); then
    git commit -m "[`thisBranch`] $message"
  else
    echo "you need to append a commit message"
  fi
}

function darker() { # <-- Wrapper for darker and iSort
  # TODO: Add mypy support
  local changed_files=($(git diff --name-only))

  for file in "${changed_files[@]}"; do
    isort --settings ./pyproject.toml $file
    black --config ./pyproject.toml $file
  done
}

function db() { # <-- Wrapper for rebuild db_replica
  rebuild db_replica
}

function goodbye() {
  printf "$fg[green]Delete$reset_color this codespace? (y to confirm)?\n‣ "
  read response
  [[ $response = "y" ]] && gh cs delete -c $CODESPACE_NAME
}

function rtest() { # <-- Wrapper to translate path to Rover test paths
  regex="src\/aplaceforrover\/?(.*)\.py"
  echo "Running tests in $1"

  if [[ -f $1 ]]; then
    step1=${string:gs/src\/aplaceforrover\//""}
    step2=${step1:gs/\.py/""}
    pythonpath=${step2:gs/\//"."}
    t $pythonpath
  else
    echo "You need to provide a valid path to a file in src/aplaceforrover"
  fi
}

function update-staging() { # <-- Wrapper for git push to staging
  git push --force origin `thisBranch`:staging-josh
}

function update-branch(){ # <-- Update the current branch with the latest changes from master
  local CURRENT_BRANCH=`thisBranch`
  local MASTER="master"

  git checkout $MASTER && git pull

  if [[ $CURRENT_BRANCH != $MASTER ]]; then
    git checkout $CURRENT_BRANCH && git rebase -i origin/master
  fi
}
