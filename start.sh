#!/bin/bash
set -euo pipefail

MAPTILES_DIR="../maptiles"
CONFIG_DIR="./config"

################################
# check_dir
#   Check if the dir exists and creates it if it doesnt
#
# Author: Domenic Chao
# parameter: DIR - the path to the dir
#
# returns: none
################################
check_dir() {
	local DIR="$1"
	if [ ! -d "$DIR" ]; then
		echo "[INFO - $(date +"%b %d %T")] Directory $DIR does not exist. Creating new folder"
		mkdir -p "$DIR"
	fi
}

# Checking to make sure all the dirs exist
check_dir "$MAPTILES_DIR"
check_dir "$CONFIG_DIR"

# Exporting Variables
export RES_MAPTILES_DIR=$(realpath "${MAPTILES_DIR}")
export RES_CONFIG_DIR=$(realpath "${CONFIG_DIR}")

# Starting Docker Container
docker compose -f "./compose-base.yaml" up -d --force-recreate --renew-anon-volumes
