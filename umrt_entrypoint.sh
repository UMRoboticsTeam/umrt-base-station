#!/usr/bin/env bash

################################
# require_file
#   Looks to see if the required file is found on the device
#
# Author: Connor 
# parameter: path - the path to the file
#
# returns: none
################################
require_file() {
  local path="$1"

  if [[ ! -f "${path}" ]]; then
    echo "[ERRO - $(date +"%b %d %T")] Missing required file: ${path}" >&2
    exit 1
  fi
}

################################
# main
#   The main section of code that runs everytime
#
# Author: Domenic Chao
# parameter: none
#
# returns: none
################################
main() {
  echo "[INFO - $(date +"%b %d %T")] Starting UMRT Basestation"

  echo "[INFO - $(date +"%b %d %T")] Sourcing ros_entrypoint.sh"
  source ./ros_entrypoint.sh
  
  echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Stack"
  echo "[INFO - $(date +"%b %d %T")] Checking File Requirements"
  require_file "${config_dir}/base-lo.json5"
  require_file "${config_dir}/base-hi.json5"

  echo "[INFO - $(date +"%b %d %T")] Launching Foxglove Bridge"
  ros2 launch foxglove_bridge foxglove_bridge_launch.xml address:=0.0.0.0 port:=8765 &

  echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base Low"
  zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base-lo.json5" &

  echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base High"
  zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base-hi.json5" &

  echo "[INFO - $(date +"%b %d %T")] Launching Arm Fireware"
  ros2 launch umrt-arm-firmware-lib joy.launch.py
}

main
