#!/bin/bash
set -euo pipefail

MAPTILES_DIR="../maptiles"
CONFIG_DIR="./config"

if [ ! -d "$MAPTILES_DIR" ]; then
  echo "Directory $MAPTILES_DIR does not exist. Creating new folder"
  mkdir -p "$MAPTILES_DIR"
fi

export RES_MAPTILES_DIR=$(realpath "${MAPTILES_DIR}")
export RES_CONFIG_DIR=$(realpath "${CONFIG_DIR}")

docker compose -f "./compose-base.yaml" up -d --force-recreate --renew-anon-volumes
