#!/bin/bash
RED_TXT="\033[31m"
RESET_TXT="\033[0m"

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
    echo -e "[${RED_TXT}ERRO${RESET_TXT} - $(date +"%b %d %T")] Missing required file: ${path}" >&2
    c_exit 
  fi
}

################################
# c_exit
#   a custom exit function that add the closing line to the function
#
# Author: Domenic Chao
# parameter: none
#
# returns: none
################################
c_exit() {
  echo -e "//*********************************************************//\n\n"
  sleep infinity 
  exit
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
  echo "//*************** UMRT BASE STATION LAUNCHER ***************//"
  echo "[INFO - $(date +"%b %d %T")] Starting UMRT Basestation"

  echo "[INFO - $(date +"%b %d %T")] Sourcing ros_entrypoint.sh"
  source ./ros_entrypoint.sh
  
  echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Stack"
  echo "[INFO - $(date +"%b %d %T")] Checking File Requirements"

  require_file "${BRIDGE_WORKSPACE}/config/base-lo.json5"
  require_file "${BRIDGE_WORKSPACE}/config/base-hi.json5"

  echo "[INFO - $(date +"%b %d %T")] Launching Foxglove Bridge"
  ros2 launch foxglove_bridge foxglove_bridge_launch.xml address:=0.0.0.0 port:=8765 &

  echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base Low"
  zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base-lo.json5" > /dev/null &

  echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base High"
  zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base-hi.json5" > /dev/null &

  echo "[INFO - $(date +"%b %d %T")] Launching Arm Firmware"
  ros2 launch umrt-arm-ros-firmware joy.launch.py &
  
  echo "[INFO - $(date +"%b %d %T")] Base-station Launch Complete Successfully"
  c_exit
}

main
