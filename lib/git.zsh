#
# Git-related functions and aliases
#
# Updated: 2025-05-07
#

function commit() { # <-- Wrapper for git commit with a message for the current branch
  local message="$*"
  if ((${#message} > 0)); then
    git commit -m "[`thisBranch`] $message"
  else
    echo "you need to append a commit message"
  fi
}


function pull() { # <-- Pull from origin repository on the current branch
  git pull origin `thisBranch`
}

function push() { # <-- Pull from origin repository on the current branch
  local FLAG=$1
  # if the parameter provided is -f or --force, force push
  if [[ $FLAG = "-f" || $FLAG = "--force" ]]; then
    printf "\n$fg[red]Force pushing to `thisBranch`$reset_color\n"
  elif [[ -n $FLAG ]]; then
    unset FLAG
    printf "\n$fg[yellow]Invalid flag provided$reset_color\n"
  fi

  git push origin `thisBranch` $FLAG
}

function update-staging() { # <-- Wrapper for git push to staging
  git push --force origin `thisBranch`:staging-josh
}

function update-base(){ # <-- Pull from the main branch and rebase the current branch
  local CURRENT_BRANCH=`thisBranch`
  local MAIN_BRANCH="master"
  local BASE_BRANCH=$1

  # If a base branch is provided, check if it exists and use that instead of master
  if [[ -n $BASE_BRANCH ]]; then
    if git show-ref --verify --quiet refs/remotes/origin/$BASE_BRANCH; then
      MAIN_BRANCH=$BASE_BRANCH
    else
      printf "\n$fg[red]The base branch $BASE_BRANCH does not exist$reset_color\n"
      unset BASE_BRANCH
    fi
  fi

  # If main exists and BASE_BRANCH is unset, use that instead of master
  if [[ -z $BASE_BRANCH ]] && git show-ref --verify --quiet refs/remotes/origin/main; then
    MAIN_BRANCH="main"
  fi

  git checkout $MAIN_BRANCH && git pull

  if [[ $CURRENT_BRANCH != $MAIN_BRANCH ]]; then
    git checkout $CURRENT_BRANCH && git rebase -i origin/$MAIN_BRANCH
  fi
}

function update-branch(){ # <-- Update the current branch from the origin
  git pull origin `thisBranch`
  git fetch
}
