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

function update-staging() { # <-- Update a staging branch with the latest changes from master
  if [[ $PWD != *"$ROVER_WEB_DIR"* ]]
    then
      printf "\n$fg[red]You must be in the Rover Web directory to run this command$reset_color\n"
      return 1
  fi

  if [[ -z $1 ]]
    then
      printf "\n$fg[red]You must provide a staging name to update$reset_color\n"
      return 1
  fi

  local staging_to_update=$1

  if [ `git branch -r | grep "staging-$staging_to_update"` ]
    then
      local CURRENT_BRANCH=`thisBranch`

      if [[ $CURRENT_BRANCH != $MASTER ]]; then
        printf "\n$fg[info]Switching to $MASTER for a sec from $CURRENT_BRANCH$reset_color\n"
        git checkout $MASTER
      fi

      git pull
      printf "\n$fg[green]Updating staging-$staging_to_update with the latest changes from $MASTER$reset_color\n"
      git push --force origin master:staging-$staging_to_update

      if [[ $CURRENT_BRANCH != $MASTER ]]; then
        printf "\n$fg[info]Switching back to $CURRENT_BRANCH$reset_color\n"
        git checkout $CURRENT_BRANCH
      fi
  else
    printf "\n$fg[red]The staging branch staging-$staging_to_update does not exist$reset_color\n"
    return 1
  fi
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

  git checkout $MAIN_BRANCH 
  git fetch
  git pull origin $MAIN_BRANCH

  if [[ $CURRENT_BRANCH != $MAIN_BRANCH ]]; then
    git checkout $CURRENT_BRANCH && git rebase -i origin/$MAIN_BRANCH
  fi
}

function update-branch(){ # <-- Update the current branch from the origin
  git pull origin `thisBranch`
  git fetch
}
