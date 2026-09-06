#!/bin/sh

# Layout Ids Left (L), Right (R)
L_MON_LAY_ID=lay_0dnFp2e2BIrlEPXM
R_MON_LAY_ID=lay_0dnFpKLFbQUUqiva

# WS Connection
WS_CONN=ws://localhost:8765

# Monitor Names
L_MON_NAME=Virtual-1
R_MON_NAME=Virtual-1

# Docker StartFile Location


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
  foxglove-studio "foxglove://open?ds=foxglove-websocket&ds.url=$encodedConUrl&layoutId=$1" --user-data-dir="$4/" &
  pid=$!
  sleep 2
  moveAndMaximize $pid "$5"
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
  echo "move and maximize window"
}


main() {
  # Open Left
  openFoxglove $L_MON_LAY_ID $WS_CONN "MON_LEFTT" "/tmp/fg_left" $L_MON_NAME

  # Open Right
  openFoxglove $R_MON_LAY_ID $WS_CONN "MON_RIHGT" "/tmp/fg_right" $R_MON_NAME

  # Start Docker Container
  source "$DOCKER_LAUNCH_FILE"
}

main
