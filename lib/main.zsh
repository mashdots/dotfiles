# 
# Generic functions.
#
# Updated: 2025-05-07
#

COMMON_COMMANDS=(
  "m generate_api_schemas                    Run this command to generate API schemas"
  "yarn run build:apiClient                  Run this from the frontend/rsdk directory to build the API client after generating API schemas"
  "rebuild db_replica                        Rebuild the database replica"
  "m dev_rebuild_browse_services_index       Rebuild the browse services index"
  "m dev_create_facilities_fixture_data      Create fixture data for facilities"
)

function help() {
  printf "$fg[green]Common Commands$reset_color\n"
  for command in "${COMMON_COMMANDS[@]}"; do
    echo $command
  done
}
