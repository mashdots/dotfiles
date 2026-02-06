#
# Git-related functions and aliases
#
# Updated: 2025-11-11
#
export LAST_MASTER_HASH_FILE="$DOTFILE_CONFIG/last_master_hash"


function commit() { # <-- Wrapper for git commit with a message for the current branch
  local should_push=false
  local flags

  for arg in "$@"; do
    if [[ $arg == "-p" || $arg == "--push" ]]; then
      should_push=true
      shift
    fi

    if [[ $arg = "-f" ]]; then
      # If the first argument is '-f', prepend "--no-verify" to the flags
      flags="--no-verify"
      shift
    fi
  done

  
  local message="$*"
  if ((${#message} > 0)); then
    flags+=" -m"
    git_command="git commit $flags \"[\`thisBranch\`] $message\""

    eval $git_command

    if [[ $should_push = true ]]; then
      push
    fi
  else
    echo "you need to append a commit message"
  fi
}

function check_master_freshness() {
  local main_branch=$(get_main_branch)
  git fetch origin $main_branch
  local current_hash=$(git rev-parse origin/$main_branch)
  local is_hash_updated=false
  local latest_hash="0"

  if [[ -f $LAST_MASTER_HASH_FILE ]]; then
    latest_hash=$(cat $LAST_MASTER_HASH_FILE)
  else
    echo 0 >| $LAST_MASTER_HASH_FILE
  fi
    
  if [[ $latest_hash != $current_hash ]]; then
    echo $current_hash >| $LAST_MASTER_HASH_FILE
    is_hash_updated=true
  fi

  echo $is_hash_updated
}

function get-jira-description() { # <-- Using the JIRA_API_TOKEN environment variable query JIRA for the issue description
  local jira_issue=$1
  local jira_base_url="https://roverdotcom.atlassian.net"

  if [[ -z $JIRA_API_TOKEN ]]; then
    printf "\n$fg[red]JIRA_API_TOKEN environment variable is not set$reset_color\n"
    return 1
  fi

  if [[ -z $jira_issue ]]; then
    printf "\n$fg[red]You must provide a JIRA issue key (e.g., PROJ-123)$reset_color\n"
    return 1
  fi

  local response=$(curl -s --request GET --url "$jira_base_url/rest/api/3/issue/$jira_issue" --user "josh.hembree@rover.com:$JIRA_API_TOKEN" --header "Accept: application/json" )

  printf "Before:\n%s\n" "$(echo $response | jq -r '.fields.summary')"
  # Remove any non-word or non-number characters from the summary, and reformat in kebab-case
  # Trim the string so the beginning and end only start with alphanumeric characters
  trimmed_summary=$(echo $response | jq -r '.fields.summary' | sed 's/[^\w*]//;s/[\W*^]//' | sed 's/[\W*]/"-"/' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -s '-')
  
  echo "After:\n$trimmed_summary"

  return $(echo $response | jq -r '.fields.summary')
}

function get_main_branch() { # <-- Return the name of the main branch, whether it's master or main
  local main_branch="master"
  
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    main_branch="main"
  fi

  echo $main_branch
}

function git-new() { # <-- Given a new branch name, will pull and fetch from the main branch, then create a new one
  local new_branch=$1
  shift
  local args=$1
  local current_branch=`thisBranch`
  local main_branch=$(get_main_branch)

  # If a new branch name is not provided, return an error
  if [[ -z $new_branch ]]; then
    printf "\n$fg[red]You must provide a new branch name$reset_color\n"
    return 1
  fi

  git checkout $main_branch && git pull


  # If args is --from-here, switch to current_branch to use as the base
  if [[ $args = "--from-here" ]]; then
    git checkout $current_branch
  fi
  
  git checkout -b $new_branch
}


function pull() { # <-- Pull from origin repository on the current branch
  local should_stash=false
  local should_fetch=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s) should_stash=true; shift;;
      -f) should_fetch=true; shift;;
      *) break;;
    esac
  done

  if [[ $should_stash = true ]]; then
    printf "\n$fg[info]Stashing changes before pulling from `thisBranch`$reset_color\n"
    git stash -u
  fi

  git pull origin `thisBranch`

  if [[ $should_fetch = true ]]; then
    printf "\n$fg[info]Fetching latest changes from origin before pulling from `thisBranch`$reset_color\n"
    git fetch origin
  fi
  
  if [[ $should_stash = true ]]; then
    printf "\n$fg[info]Popping stashed changes after pulling from `thisBranch`$reset_color\n"
    git stash pop
  fi
}

function push() { # <-- Pull from origin repository on the current branch
  local flag=$1
  # if the parameter provided is -f or --force, force push
  if [[ $flag = "-f" || $flag = "--force" ]]; then
    printf "\n$fg[red]Force pushing to `thisBranch`$reset_color\n"
  elif [[ -n $flag ]]; then
    unset flag
    printf "\n$fg[yellow]Invalid flag provided$reset_color\n"
  fi

  git push origin `thisBranch` $flag
}

function reset-branch() {
  git reset --hard origin/`thisBranch`
}

function reset-master() { # <-- Reset the master branch to the latest commit
  local current_branch=`thisBranch`
  local main_branch=$(get_main_branch)

  if [[ $current_branch != $main_branch ]]; then
    printf "\n$fg[info]Switching to $main_branch for a sec from $current_branch$reset_color\n"
    git checkout $main_branch
  fi

  git fetch origin
  git reset --hard origin/master
}


function update-base(){ # <-- Pull from the main branch and rebase the current branch
  local current_branch=`thisBranch`
  local main_branch=$(get_main_branch)
  local base_branch=$1
  local should_pull_main=$(check_master_freshness)

  # If a base branch is provided, check if it exists and use that instead of master
  if [[ -n $base_branch ]]; then
    if git show-ref --verify --quiet refs/remotes/origin/$base_branch; then
      main_branch=$base_branch
    else
      printf "\n$fg[red]The base branch $base_branch does not exist$reset_color\n"
      unset base_branch
    fi
  fi

  # If there are changes on the current branch, stash them with the current branch name
  if ! git diff-index --quiet HEAD --; then
    printf "\n$fg[yellow]Stashing changes on $current_branch before updating base branch$reset_color\n"
    git stash push -m "$current_branch changes before updating base branch" --include-untracked
  fi

  if [[ $should_pull_main = true ]]; then
    printf "\n$fg[green]Pulling latest changes from $main_branch before updating base branch$reset_color\n"
    git checkout $main_branch 
    git fetch
    git pull origin $main_branch
  fi

  if [[ $current_branch != $main_branch ]]; then
    git checkout $current_branch && git rebase -i origin/$main_branch

    if [[ $? -ne 0 ]]; then
      printf "\n$fg[red]Rebase failed. Please resolve conflicts and continue the rebase.$reset_color\n"

      # If there are stashed changes for the branch, tell the user to pop them when finished rebasing
      if git stash list | grep -q "$current_branch changes before updating base branch"; then
        printf "\n$fg[yellow]You have stashed changes for $current_branch. Please run 'git stash pop' when you are done rebasing.$reset_color\n"
      fi
      return 1
    fi

    if git stash list | grep -q "$current_branch changes before updating base branch"; then
      printf "\n$fg[green]Popping stashed changes for $current_branch after updating base branch$reset_color\n"
      git stash pop
    fi
  fi
}

function update-branch(){ # <-- Update the current branch from the origin
  git pull origin `thisBranch`
  git fetch
}

function revert-file(){ # <-- Revert a file to the last committed state based on the main branch, or a given branch name
  local main_branch=$(get_main_branch)
  local file_path=$1
  local base_branch=${2:-$main_branch}

  if [[ -z $file_path ]]; then
    printf "\n$fg[red]You must provide a file path to revert$reset_color\n"
    return 1
  fi

  git fetch origin
  git checkout origin/$base_branch -- $file_path
}
