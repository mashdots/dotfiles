# 
# Generic functions.
#
# Updated: 2025-05-07
#

help() {
  printf "$fg[green]Common Commands$reset_color\n"
  for command in "${COMMON_COMMANDS[@]}"; do
    echo $command
  done
}
