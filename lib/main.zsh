###
# Generic functions.
###

help() {
  printf "$fg[green]Common Commands$reset_color\n"
  for command in "${COMMON_COMMANDS[@]}"; do
    echo $command
  done
}
