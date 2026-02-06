#
# Functions and methods that are specific to Rover.
#
# Updated: 2026-02-05
#
export RAWS_USE_DEVICE_CODE=0
export LAST_RAWS_LOGIN_FILE="$DOTFILE_CONFIG/last_raws_login"


function maybe_login_raws() { # <-- Log in to RAWS if it has been more than 24 hours since the last login
  local now=$(date +%s)
  local last_login=0

  if [[ -f $LAST_RAWS_LOGIN_FILE ]]; then
    last_login=$(cat $LAST_RAWS_LOGIN_FILE)
  else
    echo 0 >| $LAST_RAWS_LOGIN_FILE
  fi

  local login_time_diff=$(( (now - last_login) / 3600 ))

  if (( login_time_diff >= 23 )); then
    printf "\n$fg[green]Logging in to RAWS$reset_color\n"
    raws profile dev
    echo $now >| $LAST_RAWS_LOGIN_FILE
  elif (( login_time_diff >= 20 )); then
    printf "\n$fg[blue]Last RAWS login was $login_time_diff hours ago. Log in will be triggered soon$reset_color\n"
  fi
}


function blacken() { # <-- Wrapper for black
  if [[ -f $1 ]]; then
    black --config ./pyproject.toml $1
  else
    # Get list of changed files via git diff and assign to an array, filtering out non-Python files
    local changed_files=($(git diff --name-only | grep -E '\.py$'))

    if [[ ${#changed_files[@]} -gt 0 ]]; then
      for changed_file in "${changed_files[@]}"; do
        black --config ./pyproject.toml $changed_file
      done
    else
      printf "$fg[red]WHOOPS$reset_color - no Python files to format.\n"
    fi
  fi
}

function darker() { # <-- Wrapper for darker and iSort
  # TODO: Add mypy support
  local changed_files=($(git diff --name-only))

  for changed_file in "${changed_files[@]}"; do
    if [ "${changed_file: -3}" == ".py" ]; then
      isort --settings ./pyproject.toml $changed_file
      black --config ./pyproject.toml $changed_file
    fi
  done
}

function goodbye() { # <-- Delete the current codespace
  printf "$fg[green]Delete$reset_color this codespace? (y to confirm)?\n‣ "
  read response
  [[ $response = "y" ]] && gh cs delete -c $CODESPACE_NAME
}

# function schema_time() { # <-- A wrapper that lets you quickly rebuild schemas
#   local only_python=false
#   local only_typescript=false

#   while [[ "$1" == --* ]]; do
#     case "$1" in
#       --only-python)
#         only_python=true
#         shift
#         ;;
#       --only-typescript)
#         only_typescript=true
#         shift
#         ;;
#       *)
#         echo "Unknown option: $1"
#         shift
#         ;;
#     esac
#   done
  
#   if $only_typescript; then
#     m generate_api_schemas
#   elif $only_python; then
#     (cd /workspaces/web/src/frontend/rsdk && yarn run build:apiClient)
#     m generate_api_schemas
#   else
#     m generate_api_schemas && (cd /workspaces/web/src/frontend/rsdk && yarn run build:apiClient)
#   fi
  
#   if $only_python; then
  
# }

function start() { # <-- Start all docker containers
  maybe_login_raws

  until dc up -d
  do
      echo "Trying to start . . ."
      sleep 1
  done
}

