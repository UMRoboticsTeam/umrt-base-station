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

  if [ "$BOOT_FOXGLOVE" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Foxglove Bridge"
	ros2 run foxglove_bridge foxglove_bridge --ros-args \
	  -p send_buffer_limit:=5000000 \
	  -p use_compression:=false \
	  -p max_qos_depth:=1 \
	  -p address:=0.0.0.0 \
	  -p port:=8765 \
	  -p best_effort_qos_topic_whitelist:="['.*/hf$', '^/rover/poe/encoded_video$', '^/arm_cam0/image_raw/ffmpeg$', '^/camera$']" &
  fi

  if [ "$BOOT_LO_NET" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base Low"
	require_file "${BRIDGE_WORKSPACE}/config/base_lo.json"
  	zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base_lo.json" > /dev/null &
  fi
  
  if [ "$BOOT_HI_NET" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base High"
  	require_file "${BRIDGE_WORKSPACE}/config/base_hi.json"
  	zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base_hi.json" > /dev/null &
  fi

  if [ "$BOOT_HI_F_LO_NET" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base High Fail Low"
  	require_file "${BRIDGE_WORKSPACE}/config/base_hi_f_lo.json"
  	zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base_hi_f_lo.json" > /dev/null &
  fi

  if [ "$BOOT_LO_F_HI_NET" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base Low Fail High"
  	require_file "${BRIDGE_WORKSPACE}/config/base_lo_f_hi.json"
  	zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base_lo_f_hi.json" > /dev/null &
  fi
  
  if [ "$BOOT_LOC_NET" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base Local"
  	require_file "${BRIDGE_WORKSPACE}/config/base_loc.json"
  	zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base_loc.json" > /dev/null &
  fi
  
  if [ "$BOOT_ALL_NET" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Zenoh Base All"
  	require_file "${BRIDGE_WORKSPACE}/config/base_all.json"
  	zenoh-bridge-ros2dds -c "${BRIDGE_WORKSPACE}/config/base_all.json" > /dev/null &
  fi

  if [ "$BOOT_JOYSTICK" != "false" ]; then
  	echo "[INFO - $(date +"%b %d %T")] Launching Arm Firmware"
  	ros2 launch umrt-arm-ros-firmware joy.launch.py &
  fi
  
  echo "[INFO - $(date +"%b %d %T")] Base-station Launch Complete Successfully"
  c_exit
}

main
