#!/bin/bash

# Layout Ids Left (L), Right (R)
L_MON_LAY_ID=lay_0dnFp2e2BIrlEPXM
R_MON_LAY_ID=lay_0dnFpKLFbQUUqiva

# WS Connection
WS_CONN=ws://localhost:8765

# Monitor Names
L_MON_ID=0
R_MON_ID=1

# Docker StartFile Location
DOCKER_LAUNCH_FILE="/path/to/dir/start.sh"

##########################
# openFoxglove
#  Opens foxglove on a sepecific monitor at max resolution
#
#  Parmeters (In ORDER):
#    layoutId - the layout id to open
#    connectionUrl - the url to connect to
#    montiorName - the name of the monitor
#
#  Returns: none
########################
openFoxglove() {
  encodedConUrl=$(urlEncode "$2")

  cp -r "$HOME/.config/Foxglove" "$4"
  foxglove-studio "foxglove://open?ds=foxglove-websocket&ds.url=$encodedConUrl&layoutId=$1" --user-data-dir="$4/" > /dev/null &
  pid=$!
  moveAndMaximize $pid $5
}

########################
# urlEncode
#  Encodes the string provided to a url encoded value
#  Parameter (In ORDER):
#    string - the string to encode
#
#  Returns: the encoded value
########################
urlEncode() {
  local string="$1"
  local length=${#string}
  local i=0

  while [ $i -lt $length ]; do
    local c=$(printf '%s' "$string" | cut -c $((i + 1)))

    case "$c" in
      [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
      *) printf '%%%.2X' "'$c" ;;
    esac

    i=$((i+1))
  done
}


moveAndMaximize() {
  local pid=$1
  local windowId=$2
  
  local line_num=$((windowId + 1))
  local monitorLine=$(gdbus call --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig --method org.gnome.Mutter.DisplayConfig.GetCurrentState | grep -o '\[([0-9].*)\], {.*layout-mode' | sed 's/), (/\n/g; s/[()\[]//g; s/, / /g' | sed -n "${line_num}p")
  
  XPOS=$(echo $monitorLine | awk '{print $1}')
  YPOS=$(echo $monitorLine | awk '{print $2}')
  
  if [ -z "$XPOS" ] || [ -z "$YPOS" ] || [ "$XPOS" = "null" ] || [ "$YPOS" = "null" ]; then
    echo "[WARN] No Monitor Found - Move Canceled"
    return 1
  fi
  
  sleep 2
  local frameId=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.List | sed "s/^('//;s/',)$//" | jq --argjson target_pid "$pid" '.[] | select(.pid == $target_pid) | .id')
  
  if [ -z "$frameId" ]; then
    echo "[WARN] No Window Found - Move Canceled"
    return 1
  fi
  
  gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.Move $frameId $XPOS $YPOS > /dev/null
  gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.Maximize $frameId > /dev/null
}


########################
# main
#  The section of code that runs everytime
#  Parameter (In ORDER): none
#
#  Returns: none
#######################
main() {
  # Deleting all old Networks
  docker network prune -f > /dev/null
  # Open Left
  openFoxglove $L_MON_LAY_ID $WS_CONN "MON_LEFTT" "/tmp/fg_left" $L_MON_ID

  # Open Right
  openFoxglove $R_MON_LAY_ID $WS_CONN "MON_RIHGT" "/tmp/fg_right" $R_MON_ID

  # Start Docker Container
  cd "$(dirname "$DOCKER_LAUNCH_FILE")"
  $DOCKER_LAUNCH_FILE
}

main
