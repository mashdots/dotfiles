#
# Functions and methods that are specific to Rover.
#
# Updated: 2025-05-07
#
export RAWS_USE_DEVICE_CODE=0
export LAST_RAWS_LOGIN_FILE="$HOME/last_raws_login"


function maybe-login-raws() { # <-- Log in to RAWS if it has been more than 24 hours since the last login
  local NOW=$(date +%s)
  local LAST_LOGIN=0

  if [[ -f $LAST_RAWS_LOGIN_FILE ]]; then
    LAST_LOGIN=$(cat $LAST_RAWS_LOGIN_FILE)
  else
    echo 0 >| $LAST_RAWS_LOGIN_FILE
  fi

  local DIFF=$(( (NOW - LAST_LOGIN) / 3600 ))

  if (( DIFF >= 23 )); then
    printf "\n$fg[green]Logging in to RAWS$reset_color\n"
    ~/.local/bin/raws profile dev
    echo $NOW >| $LAST_RAWS_LOGIN_FILE
  elif (( DIFF >= 20 )); then
    printf "\n$fg[blue]Last RAWS login was $DIFF hours ago. Log in will be triggered soon$reset_color\n"
  fi
}


function blacken() { # <-- Wrapper for black
  if [[ -f $1 ]]; then
    black --config ./pyproject.toml $1
  else
    # Get list of changed files via git diff and assign to an array, filtering out non-Python files
    local changed_files=($(git diff --name-only | grep -E '\.py$'))

    if [[ ${#changed_files[@]} -gt 0 ]]; then
      for file in "${changed_files[@]}"; do
        black --config ./pyproject.toml $file
      done
    else
      printf "$fg[red]WHOOPS$reset_color - no Python files to format.\n"
    fi
  fi
}

function darker() { # <-- Wrapper for darker and iSort
  # TODO: Add mypy support
  local changed_files=($(git diff --name-only))

  for file in "${changed_files[@]}"; do
    if [ "${file: -3}" == ".py" ]; then
      isort --settings ./pyproject.toml $file
      black --config ./pyproject.toml $file
    fi
  done
}

function goodbye() { # <-- Delete the current codespace
  printf "$fg[green]Delete$reset_color this codespace? (y to confirm)?\n‣ "
  read response
  [[ $response = "y" ]] && gh cs delete -c $CODESPACE_NAME
}

function rtest() { # <-- Wrapper to translate path to Rover test paths
  if [[ -f $1 ]]; then
    step1=${1:gs/src\/aplaceforrover\//""}
    step2=${step1:gs/\.py/""}
    to_test=${step2:gs/\//"."}
    echo "Running tests for $to_test"
    t "$to_test"
    echo "For future testing, run 't $to_test'"
  else
    echo "You need to provide a valid path to a file in src/aplaceforrover"
  fi
}

function start() { # <-- Start all docker containers
  maybe-login-raws


  until dc up -d
  do
      echo "Trying to start . . ."
      sleep 1
  done
}

function write_aws_saml_credentials() { # <-- Write AWS SAML credentials to file
    if [ ! -z "${ROVER_AWS_SAML_HELPER_CREDENTIALS:-}" ]; then
        mkdir -p "$HOME"/.aws
        echo "$ROVER_AWS_SAML_HELPER_CREDENTIALS" | base64 -d > "$HOME"/.aws/credentials
    fi
}

