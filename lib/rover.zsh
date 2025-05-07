#
# Functions and methods that are specific to Rover.
#
# Updated: 2025-05-07
#

function blacken() {
  if [[ -f $1 ]]; then
    black --config ./pyproject.toml $1
  else
    printf "$fg[red]WHOOPS$reset_color - you need to provide a file to format.\n"
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

function goodbye() {
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


function start() {
  until dc up -d
  do
      echo "Trying to start . . ."
      sleep 1
  done
}

