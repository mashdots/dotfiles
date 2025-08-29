#
# Git-related functions and aliases
#
# Updated: 2025-05-13
#

function commit() { # <-- Wrapper for git commit with a message for the current branch
  local message="$*"
  if ((${#message} > 0)); then
    git commit -m "[`thisBranch`] $message"
  else
    echo "you need to append a commit message"
  fi
}

function git-new() { # <-- Given a new branch name, will pull and fetch from the main branch, then create a new one
  local NEW_BRANCH=$1
  shift
  local args=$1
  local CURRENT_BRANCH=`thisBranch`
  local MAIN_BRANCH="master"

  # If a new branch name is not provided, return an error
  if [[ -z $NEW_BRANCH ]]; then
    printf "\n$fg[red]You must provide a new branch name$reset_color\n"
    return 1
  fi

  # If main exists, use that instead of master
  if git show-ref --verify --quiet refs/heads/main; then
    MAIN_BRANCH="main"
  fi

  git checkout $MAIN_BRANCH && git pull


  # If args is --from-here, switch to CURRENT_BRANCH to use as the base
  if [[ $args = "--from-here" ]]; then
    git checkout $CURRENT_BRANCH
  fi
  
  git checkout -b $NEW_BRANCH
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

function reset-branch() {
  git reset --hard origin/`thisBranch`
}

function reset-master() { # <-- Reset the master branch to the latest commit
  local CURRENT_BRANCH=`thisBranch`

  if [[ $CURRENT_BRANCH != $MASTER ]]; then
    printf "\n$fg[info]Switching to $MASTER for a sec from $CURRENT_BRANCH$reset_color\n"
    git checkout $MASTER
  fi

  git fetch origin
  git reset --hard origin/master
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

  # If there are changes on the current branch, stash them with the current branch name
  if ! git diff-index --quiet HEAD --; then
    printf "\n$fg[yellow]Stashing changes on $CURRENT_BRANCH before updating base branch$reset_color\n"
    git stash push -m "$CURRENT_BRANCH changes before updating base branch" --include-untracked
  fi

  git checkout $MAIN_BRANCH 
  git fetch
  git pull origin $MAIN_BRANCH

  if [[ $CURRENT_BRANCH != $MAIN_BRANCH ]]; then
    git checkout $CURRENT_BRANCH && git rebase -i origin/$MAIN_BRANCH

    if [[ $? -ne 0 ]]; then
      printf "\n$fg[red]Rebase failed. Please resolve conflicts and continue the rebase.$reset_color\n"

      # If there are stashed changes for the branch, tell the user to pop them when finished rebasing
      if git stash list | grep -q "$CURRENT_BRANCH changes before updating base branch"; then
        printf "\n$fg[yellow]You have stashed changes for $CURRENT_BRANCH. Please run 'git stash pop' when you are done rebasing.$reset_color\n"
      fi
      return 1
    fi

    if git stash list | grep -q "$CURRENT_BRANCH changes before updating base branch"; then
      printf "\n$fg[green]Popping stashed changes for $CURRENT_BRANCH after updating base branch$reset_color\n"
      git stash pop
    fi
  fi
}

function update-branch(){ # <-- Update the current branch from the origin
  git pull origin `thisBranch`
  git fetch
}
